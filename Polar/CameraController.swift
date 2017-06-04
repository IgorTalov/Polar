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
    
    var currentCameraPosition: CameraPosition?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    
    var photoOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var flashMode: AVCaptureFlashMode?
}

extension CameraController {
    func prepare(complitionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
            self.flashMode = .off
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
                        device.focusMode = .continuousAutoFocus
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
            } else if let frontCamera = self.frontCamera {
             
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(self.frontCameraInput) {
                    captureSession.addInput(self.frontCameraInput)
                }
                
                self.currentCameraPosition = .front
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
}
