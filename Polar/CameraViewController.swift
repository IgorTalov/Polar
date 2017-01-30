//
//  CameraViewController.swift
//  Polar
//
//  Created by Игорь Талов on 01.11.16.
//  Copyright © 2016 Игорь Талов. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    @IBOutlet weak var shutterButton: UIButton!
    @IBOutlet weak var reverseButton: UIButton!
    @IBOutlet weak var previewView: UIView?
//    @IBOutlet weak var headerView: UIView?
    @IBOutlet weak var actionsView: UIView?
    @IBOutlet weak var HDRButton: UIButton?
    @IBOutlet weak var buttonsView: UIView?
    
    let captureSession = AVCaptureSession()
    
    var gridView : GridView!
    
    var curretCaptureDevice : AVCaptureDevice?
    var backCaptureDevice : AVCaptureDevice?
    var frontCaptureDevice : AVCaptureDevice?
    var captureOutput : AVCaptureStillImageOutput?
    var captureConnection : AVCaptureConnection?
    var isLockForTouch: Bool = false
    var timeForUnlock: CGFloat = 0.7
    var showGrid : Bool = false
    var isHDR : Bool = false
    var photoAlbum = PolarAlbum()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSession()

        self.shutterButton.layer.cornerRadius = self.shutterButton.bounds.size.width / 2
        self.shutterButton.layer.borderColor = UIColor.darkGray.cgColor
        self.shutterButton.layer.borderWidth = 3.0
        
        setShutterView()
//        configureGrid()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setShutterView() {
        
        var gradientLayer = CAGradientLayer()
        gradientLayer.frame = (self.buttonsView?.bounds)!
        gradientLayer.colors = [UIColor.lightGray.cgColor, UIColor.black.cgColor]
        gradientLayer.opacity = 0.48
        self.buttonsView?.backgroundColor = UIColor.clear
        self.buttonsView?.layer.addSublayer(gradientLayer)
    }
    
//    func configureGrid() {
    
//        let rect = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.size.width, height: self.view.bounds.size.height - CGFloat((self.headerView?.frame.size.height)! + (self.actionsView?.frame.size.height)!))
//        
//        self.gridView = GridView(frame: rect, numberOfColumns: 3, numberOfRows: 3)
//        self.previewView?.addSubview(self.gridView)
//        self.showGrid = true
//    }
    
    func configureSession() {
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        
        for device in devices! {
            if (device as AnyObject).hasMediaType(AVMediaTypeVideo) {
                if (device as AnyObject).position == AVCaptureDevicePosition.back {
                    backCaptureDevice = device as? AVCaptureDevice
                } else if (device as AnyObject).position == AVCaptureDevicePosition.front {
                    frontCaptureDevice = device as? AVCaptureDevice
                }
            }
        }
        
        curretCaptureDevice = backCaptureDevice
        
        if curretCaptureDevice != nil {
            beginSession()
        }
    }
    
    func configureCapture () {
        captureOutput = AVCaptureStillImageOutput()
        
        let outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
        captureOutput?.outputSettings = outputSettings
        self.captureSession.addOutput(captureOutput)
        
        for connection:AVCaptureConnection in captureOutput?.connections as! [AVCaptureConnection] {
            
            for port:AVCaptureInputPort in connection.inputPorts! as! [AVCaptureInputPort] {
                if port.mediaType == AVMediaTypeVideo {
                    captureConnection = connection as AVCaptureConnection
                    break
                }
            }
            if captureConnection != nil {
                break
            }
        }
        
    }
    
    func beginSession() {
        
        let videoInput: AVCaptureDeviceInput?
        
        do {
            videoInput = try AVCaptureDeviceInput(device: backCaptureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput){
            captureSession.addInput(videoInput)
        } else {
            //just ignore
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewView?.layer.addSublayer(previewLayer!)
        previewLayer?.frame = self.view.layer.frame
        configureCapture()
        captureSession.startRunning()
    }
    
    func configureDevice() {
        if let device = backCaptureDevice {
            do {
                try device.lockForConfiguration()
            } catch {
                return
            }
            device.focusMode = .locked
            device.unlockForConfiguration()
        }
    }
    
    //MARK: Set Focus
    func focusTo(value: CGFloat) {
        if let device = backCaptureDevice {
            
            do {
                try device.lockForConfiguration()
                device.setFocusModeLockedWithLensPosition(Float(value), completionHandler: { (time) -> Void in
                })
                device.unlockForConfiguration()
            } catch {
                // just ignore
            }
        }
    }
    
    //MARK: Set ISO
    func setISOTo(value: Float) {
        if let device = backCaptureDevice {
            let minISO = device.activeFormat.minISO
            let maxISO = device.activeFormat.maxISO
            let clampedISO = value * (maxISO - minISO) + minISO
            //            print(clampedISO)
            do {
                try device.lockForConfiguration()
                device.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, iso: clampedISO, completionHandler: { (time) in
                    
                })
                device.unlockForConfiguration()
            } catch {
                // just ignore
            }
        }
    }
    
    
    //MARK: Configure Touch Action
    let screenWidth = UIScreen.main.bounds.size.width
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let anyTouch = touches.first
        let touchPercent = (anyTouch?.location(in: self.view).x)! / screenWidth
        focusTo(value: touchPercent)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let anyTouch = touches.first
        let touchPercent = (anyTouch?.location(in: self.view).x)! / screenWidth
        focusTo(value: touchPercent)
    }
    
    //MARK: Take Photo
    func takePhoto() {
        if isHDR {
            if let output = captureOutput {
                DispatchQueue.global().async {
                    let connection = output.connection(withMediaType: AVMediaTypeVideo)
                    
                    let settings = [-1.0, 0.0, 2.0].map {
                        (bias: Float) -> AVCaptureAutoExposureBracketedStillImageSettings in
                        AVCaptureAutoExposureBracketedStillImageSettings.autoExposureSettings(withExposureTargetBias: bias)
                    }
                    
                    output.captureStillImageBracketAsynchronously(from: connection, withSettingsArray: settings, completionHandler: { (imageBuffer, settings, error) in
                        if imageBuffer != nil {
                            
                            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageBuffer)
                            let image = UIImage(data: imageData!)
                            var imageSave = UIImage()
                            let deviceOrientation = UIDevice.current.orientation
                            
                            imageSave = self.setOrintationForImage(orinetation: deviceOrientation, image: image!)
                            
                            self.photoAlbum.saveImage(image: imageSave)
                        }
                    })
                }
            } else {
                print("output is not captureOutput")
            }
        } else {
            if let output = captureOutput {
                DispatchQueue.global().async {
                    let connection = output.connection(withMediaType: AVMediaTypeVideo)
                    output.captureStillImageAsynchronously(from: connection, completionHandler: { (imageBuffer, error) in
                        if imageBuffer != nil {
                            
                            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageBuffer)
                            let image = UIImage(data: imageData!)
                            var imageSave = UIImage()
                            let deviceOrientation = UIDevice.current.orientation
                            
                            imageSave = self.setOrintationForImage(orinetation: deviceOrientation, image: image!)
                            
                            self.photoAlbum.saveImage(image: imageSave)
                        }
                    })
                }
            } else {
                print("output is not captureOutput")
            }
        }
    }
    
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
        default:
            print(" -> Error al reconocer device orientation")
        }
        
        return imageS
    }
    
    //MARK: Add Grid Lines
    
    func addGridLines() {
        if !showGrid {
            showGrid = true
            self.gridView.isHidden = false
        } else {
            showGrid = false
            self.gridView.isHidden = true
        }
    }
    
    //MARK: Actions
    @IBAction func shutterPressedDown(_ sender: UIButton)
    {
        //TODO: Magic
        takePhoto()
    }
    
    @IBAction func changeCamera(_ sender: UIButton)
    {
        //TODO: Magic
    }
    
    @IBAction func manualFocusSet(_sender: UISlider)
    {
        focusTo(value: CGFloat(_sender.value))
    }
    
    @IBAction func manualISOSet(_sender: UISlider)
    {
        setISOTo(value: _sender.value)
    }
    //MARK: Grid Action
    @IBAction func addGridLines(_sender: UIButton)
    {
        addGridLines()
    }
    //MARK:Set HDR
    @IBAction func setHDR(_sender: UIButton)
    {
        let imageOn = UIImage(named: "HDR on")
        let imageOff = UIImage(named: "HDR off")
        
        if isHDR {
            self.HDRButton?.setImage(imageOff, for: .normal)
            self.isHDR = false
        } else {
            self.HDRButton?.setImage(imageOn, for: .normal)
            self.isHDR = true
        }
    }

    @IBAction func closeController(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
}

