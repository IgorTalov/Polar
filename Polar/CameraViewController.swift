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
    
    var captureDevice : AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        print(devices)
        
        for device in devices! {
            if (device as AnyObject).hasMediaType(AVMediaTypeVideo) {
                if (device as AnyObject).position == AVCaptureDevicePosition.back {
                    captureDevice = device as? AVCaptureDevice
                }
            }
        }
        if captureDevice != nil {
            beginSession()
        }

        self.shutterButton.layer.cornerRadius = self.shutterButton.bounds.size.width / 2
        self.shutterButton.layer.borderColor = UIColor.darkGray.cgColor
        self.shutterButton.layer.borderWidth = 3.0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func beginSession() {
        
        let videoInput: AVCaptureDeviceInput?
        
        do {
            videoInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput){
            captureSession.addInput(videoInput)
        } else {
//            print(error?.localizedDescription)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewView?.layer.addSublayer(previewLayer!)
        previewLayer?.frame = self.view.layer.frame
        captureSession.startRunning()
    }
    
    func configureDevice() {
        if let device = captureDevice {
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
        if let device = captureDevice {
            
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
        if let device = captureDevice {
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
    
    //MARK: Actions
    @IBAction func shutterPressedDown(_ sender: UIButton)
    {
        //TODO: Magic
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

