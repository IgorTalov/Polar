//
//  Filter.swift
//  Polar
//
//  Created by Игорь Талов on 14.01.17.
//  Copyright © 2017 Игорь Талов. All rights reserved.
//

import UIKit
import GPUImage

class Filter: NSObject  {
    
    override init() {
        super.init()
    }
    
    //MARK: Filter methods
    public func brightImage(image:UIImage) -> UIImage {
        let brightFilter = BrightnessAdjustment()
        brightFilter.brightness = 0.5
        let filterImage = image.filterWithOperation(brightFilter)
        
        return filterImage
    }
    
    public func myFilterForImage(image:UIImage) -> UIImage {
        let brightFilter = BrightnessAdjustment()
        let contrastFilter = ContrastAdjustment()
        let saturationFilter = SaturationAdjustment()
        contrastFilter.contrast = 0.9
        brightFilter.brightness = 0.5
        saturationFilter.saturation = 0.3
        
        let filterImage = image.filterWithPipeline { (input, output) in
            input --> brightFilter --> contrastFilter  --> saturationFilter --> output
        }
        
        return filterImage
    }
}
