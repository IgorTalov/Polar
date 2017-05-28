//
//  Extensions.swift
//  Polar
//
//  Created by Игорь Талов on 28.05.17.
//  Copyright © 2017 Игорь Талов. All rights reserved.
//

import UIKit

extension String {
    var firstCharacterUppercased: String {
        guard case let c = self.characters,
            let c1 = c.first else { return self }
        return String(c1).uppercased() + String(c.dropFirst())
    }
}

extension UIColor {
    static func rgbColor(red:CGFloat, green:CGFloat, blue:CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

extension UIView {
    func addConstraintsWithFormat(format: String, views:UIView...) {
        
        var viewsDictinary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictinary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictinary))
    }
}
