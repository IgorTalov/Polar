//
//  ShutterButton.swift
//  Polar
//
//  Created by Игорь Талов on 12.06.17.
//  Copyright © 2017 Игорь Талов. All rights reserved.
//

import UIKit

class ShutterButton: UIButton {

    override var isHighlighted: Bool {
        didSet {
            self.backgroundColor = isHighlighted ? UIColor.lightGray : UIColor.white
        }
    }
    
}
