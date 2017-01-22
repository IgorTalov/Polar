//
//  GalleryViewCell.swift
//  Polar
//
//  Created by Игорь Талов on 21.11.16.
//  Copyright © 2016 Игорь Талов. All rights reserved.
//

import UIKit

class GalleryViewCell: UICollectionViewCell {
 
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let rect = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        
        imageView = UIImageView(frame: rect)
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        self.contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
