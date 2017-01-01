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
    
    @IBOutlet weak var viewForImage: UIView!
    @IBOutlet weak var shutterButton: UIButton!
    @IBOutlet weak var reverseButton: UIButton!
//    @IBOutlet weak var focusSlider: UISlider?
//    @IBOutlet weak var ISOSlider: UISlider?
    @IBOutlet weak var previewView: UIView?

    let captureSession = AVCaptureSession()
    
    var curretCaptureDevice : AVCaptureDevice?
    var backCaptureDevice : AVCaptureDevice?
    var frontCaptureDevice : AVCaptureDevice?
    var captureOutput : AVCaptureStillImageOutput?
    var captureConnection : AVCaptureConnection?
    var isLockForTouch: Bool = false
    var timeForUnlock: CGFloat = 0.7
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureSession()

        self.shutterButton.layer.cornerRadius = self.shutterButton.bounds.size.width / 2
        self.shutterButton.layer.borderColor = UIColor.darkGray.cgColor
        self.shutterButton.layer.borderWidth = 3.0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
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
        
        var outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
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
        if let output = captureOutput {
            DispatchQueue.global().async {
                
                let connection = output.connection(withMediaType: AVMediaTypeVideo)
                
                output.captureStillImageAsynchronously(from: connection, completionHandler: { (imageBuffer, error) in
                    if imageBuffer != nil {
                        
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageBuffer)
                        let image = UIImage(data: imageData!)
                        let deviceOrientation = UIDevice.current.orientation
                        
                        UIImageWriteToSavedPhotosAlbum(image!, self, nil, nil)
                    }
                    
                })
            }
        } else {
            print("output is not captureOutput")
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

}

