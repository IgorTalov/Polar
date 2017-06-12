//
//  CameraController.swift
//  Polar
//
//  Created by Игорь Талов on 03.06.17.
//  Copyright © 2017 Игорь Талов. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: NSObject {

    var captureSession: AVCaptureSession?
    
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?
    var currentCaptureDevice: AVCaptureDevice?
    
    var currentCameraPosition: CameraPosition?
    var focusMode: CameraControllerFocusMode?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    
    var photoOutput: AVCaptureStillImageOutput?
    var currentOutput: AVCaptureStillImageOutput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var flashMode: AVCaptureFlashMode?
    
    var photoComplitionBlock: ((UIImage?, Error?) -> Void)?
}

extension CameraController {
    func prepare(complitionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
            self.captureSession?.sessionPreset = AVCaptureSessionPresetPhoto
            self.flashMode = .off
            self.focusMode = .auto
        }
        func configureCaptureDevices() throws {
            
            guard let devices = AVCaptureDevice.devices() else { throw CameraControllerError.noCamerasAvailable }
            for device in devices as! [AVCaptureDevice] {
                if (device as AnyObject).hasMediaType(AVMediaTypeVideo) {
                    if (device as AnyObject).position == AVCaptureDevicePosition.front {
                        self.frontCamera = device as AVCaptureDevice!
                    }
                    
                    if (device as AnyObject).position == AVCaptureDevicePosition.back {
                        self.rearCamera = device as AVCaptureDevice!
                        
                        try device.lockForConfiguration()
                        device.focusMode = .autoFocus
                        device.unlockForConfiguration()
                    }
                }
            }
        }
        
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput) {
                    captureSession.addInput(self.rearCameraInput)
                }
                
                self.currentCameraPosition = .rear
                self.currentCaptureDevice = self.rearCamera
            } else if let frontCamera = self.frontCamera {
             
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(self.frontCameraInput) {
                    captureSession.addInput(self.frontCameraInput)
                }
                
                self.currentCameraPosition = .front
                self.currentCaptureDevice = self.frontCamera
            } else {
               throw CameraControllerError.noCamerasAvailable
            }
        }
        
        func configurePhotoOutputs() throws {
        
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
        
            self.photoOutput = AVCaptureStillImageOutput()
            
            let outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            self.photoOutput?.outputSettings = outputSettings
            
            if captureSession.canAddOutput(self.photoOutput) {
                captureSession.addOutput(self.photoOutput)
            }
            
            captureSession.startRunning()
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutputs()
            }
            
            catch {
                
                DispatchQueue.main.async {
                    complitionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                complitionHandler(nil)
            }
        }
    }
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
    
    func switchCameras() throws {
        guard let currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        captureSession.beginConfiguration()
        
        func switchToFrontCamera() throws {
            guard let inputs = captureSession.inputs as? [AVCaptureInput], let rearCameraInput = self.rearCameraInput, inputs.contains(rearCameraInput),
                let frontCamera = self.frontCamera else { throw CameraControllerError.invalidOperation }
            
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            captureSession.removeInput(rearCameraInput)
            
            if captureSession.canAddInput(self.frontCameraInput!) {
                captureSession.addInput(self.frontCameraInput!)
                
                self.currentCaptureDevice = self.frontCamera
                self.currentCameraPosition = .front
            }
                
            else { throw CameraControllerError.invalidOperation }
        }
        
        func switchToRearCamera() throws {
            guard let inputs = captureSession.inputs as? [AVCaptureInput], let frontCameraInput = self.frontCameraInput, inputs.contains(frontCameraInput),
                let rearCamera = self.rearCamera else { throw CameraControllerError.invalidOperation }
            
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            
            captureSession.removeInput(frontCameraInput)
            
            if captureSession.canAddInput(self.rearCameraInput!) {
                captureSession.addInput(self.rearCameraInput!)
                
                self.currentCaptureDevice = self.rearCamera
                self.currentCameraPosition = .rear
            }
                
            else { throw CameraControllerError.invalidOperation }
        }
        
        switch currentCameraPosition {
        case .front:
            try switchToRearCamera()
            
        case .rear:
            try switchToFrontCamera()
        }

        captureSession.commitConfiguration()
    }
    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void){
        if let captureSession = captureSession, captureSession.isRunning {
            if let output = self.photoOutput {
                DispatchQueue.global().async {
                    let connection = output.connection(withMediaType: AVMediaTypeVideo)
                    output.captureStillImageAsynchronously(from: connection, completionHandler: { (imageBuffer, error) in
                        if imageBuffer != nil {
                            
                            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageBuffer)
                            let image = UIImage(data: imageData!)
                            
                            let deviceOrientation = UIDevice.current.orientation
                            
                            let imageSave = self.setOrintationForImage(orinetation: deviceOrientation, image: image!) as UIImage!
                            
                            completion(imageSave, nil)
//                            self.photoAlbum.saveImage(image: imageSave)
                        }
                    })
                }
            }
        } else {
            completion(nil, CameraControllerError.unknown)
        }
    }
}

extension CameraController {
    func setOrintationForImage(orinetation: UIDeviceOrientation, image: UIImage) -> UIImage {
        
        var imageS = UIImage()
        
        switch orinetation.rawValue {
        case 1:
            imageS = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .right)
            break
        case 2:
            imageS = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .left)
            break
        case 3:
            imageS = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .up)
            break
        case 4:
            imageS = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .down)
            break
        default:
            print(" -> Error al reconocer device orientation")
        }
        
        return imageS
    }
}

extension CameraController {
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case rear
    }
    
    public enum CameraControllerFocusMode {
        case auto
        case manual
    }
}

extension CameraController {
    
    func setupFocusTo(value: CGFloat) { }
    
    func setupFocusForPoint(point: CGPoint, inView: UIView) {
        
        let focus_x = point.x / inView.frame.size.width
        let focus_y = point.y / inView.frame.size.height
        
        if let captureDevice = self.currentCaptureDevice {
            if (captureDevice.isFocusModeSupported(.autoFocus) && captureDevice.isFocusPointOfInterestSupported) {
                do {
                    try captureDevice.lockForConfiguration()
                    captureDevice.focusMode = .autoFocus
                    captureDevice.focusPointOfInterest = CGPoint(x: focus_x, y: focus_y)
                    
                    if (captureDevice.isExposureModeSupported(.autoExpose) && captureDevice.isExposurePointOfInterestSupported) {
                        captureDevice.exposureMode = .autoExpose;
                        captureDevice.exposurePointOfInterest = CGPoint(x: focus_x, y: focus_y);
                    }
                    
                    captureDevice.unlockForConfiguration()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func setupISO(value: CGFloat) { }
}
