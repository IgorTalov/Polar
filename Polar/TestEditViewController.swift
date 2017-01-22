//
//  TestEditViewController.swift
//  Polar
//
//  Created by Игорь Талов on 15.01.17.
//  Copyright © 2017 Игорь Талов. All rights reserved.
//

import UIKit
import GPUImage

class TestEditViewController: UIViewController {

    @IBOutlet weak var brightSlider: UISlider?
    @IBOutlet weak var contrastSlider: UISlider?
    @IBOutlet weak var expoSlider: UISlider?
    @IBOutlet weak var saturSlider: UISlider?
    
    var currentImageView: RenderView!
    
    public var currentImage: UIImage!
    var pictureInput: PictureInput!
    var brightFilter: BrightnessAdjustment!
    var contrastFilter: ContrastAdjustment!
    var saturationFilter: SaturationAdjustment!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentImageView = RenderView()
        currentImageView.frame = CGRect(x: 0, y: 78, width: 320, height: 200)
        
//        self.currentImage = UIImage(named: "testImage")
        pictureInput = PictureInput(image: self.currentImage)
        imageProcess()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imageProcess() {
        brightFilter = BrightnessAdjustment()
        contrastFilter = ContrastAdjustment()
        saturationFilter = SaturationAdjustment()
        contrastFilter.contrast = (self.contrastSlider?.value)!
        brightFilter.brightness = (self.brightSlider?.value)!
        saturationFilter.saturation = (self.saturSlider?.value)!
        
        pictureInput --> saturationFilter --> currentImageView
        
        pictureInput.processImage()
    }
    
    //MARK: Actions
    
    @IBAction func changeBright(_sender: UISlider) {
        imageProcess()
    }
    
    @IBAction func changeContrast(_sender: UISlider) {
        imageProcess()
    }
    
    @IBAction func changeSaturation(_sender: UISlider) {
        imageProcess()
    }

}
