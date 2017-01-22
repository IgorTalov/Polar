//
//  GridView.swift
//  Polar
//
//  Created by Игорь Талов on 04.01.17.
//  Copyright © 2017 Игорь Талов. All rights reserved.
//

import UIKit

class GridView: UIView {

    var numberOfColumns : Int
    var numberOfRows : Int
    let gridWidth = 0.5
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    init(frame:CGRect, numberOfColumns: Int, numberOfRows: Int) {
        self.numberOfColumns = numberOfColumns
        self.numberOfRows = numberOfRows
        super.init(frame: frame)
        self.isOpaque = false
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        drawGridLines()
    }
 
    func drawGridLines() {
        let contex: CGContext = UIGraphicsGetCurrentContext()!
        contex.setLineWidth(CGFloat(gridWidth))
        contex.setStrokeColor(UIColor.lightGray.cgColor)
        
        let columnWidth: CGFloat = self.frame.size.width / (CGFloat(self.numberOfColumns))
        let rowHight: CGFloat = self.frame.size.height / (CGFloat(self.numberOfRows))
        
        //Draw Columns
        for i in 0...self.numberOfColumns {
            let startPoint : CGPoint = CGPoint(x: columnWidth * CGFloat(i), y: 0.0)
            let endPoint : CGPoint = CGPoint(x: startPoint.x, y: self.frame.size.height)
            
            contex.move(to: startPoint)
            contex.addLine(to: endPoint)
            contex.strokePath()
        }
        
        //Draw Rows
        for j in 0...self.numberOfRows {
            let startPoint : CGPoint = CGPoint(x: 0.0, y: rowHight * CGFloat(j))
            let endPoint : CGPoint = CGPoint(x: self.frame.size.width, y: startPoint.y)
            
            contex.move(to: startPoint)
            contex.addLine(to: endPoint)
            contex.strokePath()
        }
    }
    
}
