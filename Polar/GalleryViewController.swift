//
//  GalleryViewController.swift
//  Polar
//
//  Created by Игорь Талов on 04.11.16.
//  Copyright © 2016 Игорь Талов. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PictureCell"

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Outlets
    @IBOutlet weak var photoCollectionView: UICollectionView?
    @IBOutlet weak var addButton: UIBarButtonItem?
    @IBOutlet weak var cameraButton: UIBarButtonItem?
    
    var photoAlbum = PolarAlbum()
    var photosFromAlbum = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.photoCollectionView!.register(GalleryViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        reloadDisplay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadDisplay()
    }
    
    //MARK: Reload Display
    func reloadDisplay() {
        self.photosFromAlbum = photoAlbum.showImages()
        DispatchQueue.main.async {
            self.photoCollectionView?.reloadData()
            self.photoCollectionView?.performBatchUpdates(nil, completion: nil)
        }

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

     func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photosFromAlbum.count
    }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GalleryViewCell
    
        let image = self.photosFromAlbum.object(at: indexPath.row) as! UIImage
        
//        cell.backgroundColor = UIColor.orange
        cell.imageView.image = image
        
        return cell
    }

    // MARK: UICollectionViewDelegate

     func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Uncomment this method to specify if the specified item should be selected
     func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

     func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }
 
    //MARK: Actions
    
    @IBAction func showCameracontroller (_ sender: UIBarButtonItem) {
        let cameraViewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CameraViewController") as UIViewController
        self.present(cameraViewController, animated: true, completion: nil)
    }
}
