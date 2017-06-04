//
//  ViewController.swift
//  Polar
//
//  Created by Игорь Талов on 04.06.17.
//  Copyright © 2017 Игорь Талов. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var shutterButton: UIButton = {
        let button = UIButton(type: .system)
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

    let capturePreviewView: UIView = {
        let previewView = UIView()
        previewView.backgroundColor = UIColor.gray
        return previewView
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
        capturePreviewView.frame = self.view.frame

        shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        shutterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        shutterButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        shutterButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        changeCameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        changeCameraButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        changeCameraButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        changeCameraButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }

    //MARK: Actions
    
    func captureImage() {
        
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
        } else {
            cameraController.flashMode = .on
        }
    }
    
    func switchCameras() {
        do {
            try cameraController.switchCameras()
        }
            
        catch {
            print(error)
        }
    }
}












