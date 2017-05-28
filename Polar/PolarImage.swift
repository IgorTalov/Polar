//
//  PolarImage.swift
//  Polar
//
//  Created by Игорь Талов on 28.05.17.
//  Copyright © 2017 Игорь Талов. All rights reserved.
//

import UIKit

class PolarImage: NSObject {

    var imageSettings: [String: AnyObject]?
    var previewImage: UIImage?
    var currentImage: CGImage
    var processedImage: CGImage?

    init(image: UIImage, imageSettings: [String: AnyObject]) {
        currentImage = image.cgImage!
    }
    
    
    
}
