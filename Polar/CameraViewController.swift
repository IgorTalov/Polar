//
//  CameraViewController.swift
//  Polar
//
//  Created by Игорь Талов on 01.11.16.
//  Copyright © 2016 Игорь Талов. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    
    @IBOutlet weak var viewForImage: UIView!
    @IBOutlet weak var shutterButton: UIButton!
    @IBOutlet weak var reverseButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shutterButton.layer.cornerRadius = 22.0
        self.shutterButton.layer.borderColor = UIColor.darkGray.cgColor
        self.shutterButton.layer.borderWidth = 3.0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}

