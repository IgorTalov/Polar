//
//  EditorViewController.swift
//  Polar
//
//  Created by Игорь Талов on 21.11.16.
//  Copyright © 2016 Игорь Талов. All rights reserved.
//

import UIKit
import GPUImage

let presetCollectionViewCellIdentifier = "PresetCell"

class EditorViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var presetsCollectionView: UICollectionView?
    @IBOutlet weak var currentImageView: UIImageView?
    
    var currentImage: UIImage!
    var presetImage: UIImage!
    var presetItems: NSMutableArray!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presetsCollectionView?.delegate = self
        self.presetsCollectionView?.dataSource = self
    
        self.currentImage = UIImage(named: "testImage")
        self.currentImageView?.image = self.currentImage
        
        self.presetItems = configureItems()
        presetsCollectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Configure
    
    func configureItems() -> NSMutableArray {
        
        var tempItemsArray: NSMutableArray = []
        
        for i in 0..<9 {
            let tempItem = PresetItem()
            tempItem.image = UIImage(named: "presetImage")
            tempItem.title = "Preset#\(i)"
            tempItemsArray.add(tempItem)
        }
        
        return tempItemsArray
    }
    
    //MARK: UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presetItems.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: presetCollectionViewCellIdentifier, for: indexPath) as! PresetViewCell
        
        let item = presetItems.object(at: indexPath.row) as! PresetItem
        
        cell.imageView?.image = item.image
        cell.titleLabel?.text = item.title
        
        return cell
    }
    
    //MARK: UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Select Item # \(indexPath.row)")
    }
    
    
}
