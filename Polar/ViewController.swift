//
//  ViewController.swift
//  Polar
//
//  Created by Игорь Талов on 04.06.17.
//  Copyright © 2017 Игорь Талов. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    lazy var shutterButton: ShutterButton = {
        let button = ShutterButton(type: .custom)
        button.backgroundColor = UIColor.white
        button.tintColor = UIColor.white
        button.layer.cornerRadius = 35
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 4
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(captureImage), for: .touchUpInside)
        return button
    }()
    
    lazy var changeCameraButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "changeCamera")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(switchCameras), for: .touchUpInside)
        return button
    }()
    
    lazy var flashToogleButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.clear
        button.tintColor = UIColor.white
        button.setImage(#imageLiteral(resourceName: "flashoff"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        return button
    }()

    let capturePreviewView: UIView = {
        let previewView = UIView()
        previewView.backgroundColor = UIColor.gray
        return previewView
    }()
    
    let focusLayer: CALayer = {
        let layer = CALayer()
        layer.borderColor = UIColor.green.cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 25
        layer.backgroundColor = UIColor.clear.cgColor
        return layer
    }()
    
    let cameraController = CameraController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        configureCameraController()
    }
    
    //MARK: Setup Views
    
    func setupViews() {
        view.addSubview(capturePreviewView)
        view.addSubview(shutterButton)
        view.addSubview(changeCameraButton)
        view.addSubview(flashToogleButton)
        capturePreviewView.frame = self.view.frame
        capturePreviewView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapToFocus)))
        
        //need Constraint
        shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        shutterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        shutterButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        shutterButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        changeCameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        changeCameraButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        changeCameraButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        changeCameraButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        flashToogleButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        flashToogleButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        flashToogleButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        flashToogleButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }


    //MARK: Actions
    
    func captureImage() {
        cameraController.captureImage { (image, error) in
            if error != nil {
                print("\(error)")
                return
            }
            
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: image!)
            }
        }
    }

    func configureCameraController() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            try? self.cameraController.displayPreview(on: self.capturePreviewView)
        }
    }
    
    func toggleFlash() {
        if cameraController.flashMode == .on {
            cameraController.flashMode = .off
            flashToogleButton.tintColor = UIColor.white
        } else {
            cameraController.flashMode = .on
            flashToogleButton.tintColor = UIColor.yellow
        }
    }
    
    func switchCameras() {
        do {
            try cameraController.switchCameras()
        } catch {
            print(error)
        }
    }
    
    //MARK: Touches handler
    
    func handleTapToFocus(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let focusPoint = sender.location(in: capturePreviewView)
            focusLayer.frame = CGRect(x: focusPoint.x - 25, y: focusPoint.y - 25, width: 50, height: 50)
            capturePreviewView.layer.addSublayer(focusLayer)
            cameraController.setupFocusForPoint(point: focusPoint, inView: capturePreviewView)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // your code here
                self.focusLayer.removeFromSuperlayer()
                self.focusLayer.frame = CGRect.zero
            }
        }
    }
}
