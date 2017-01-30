//
//  GalleryViewController.swift
//  Polar
//
//  Created by Игорь Талов on 04.11.16.
//  Copyright © 2016 Игорь Талов. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PictureCell"
private let segueEditIdentifier = "goToEditSegue"
private let segueCameraIdentifier = "showCameraSegue"

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Outlets
    @IBOutlet weak var photoCollectionView: UICollectionView?
    @IBOutlet weak var addButton: UIBarButtonItem?
    @IBOutlet weak var cameraButton: UIBarButtonItem?
    @IBOutlet weak var backgroundImageView: UIImageView?
    
    var photoAlbum = PolarAlbum()
    var photosFromAlbum = NSMutableArray()
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.lightGray
        setNavigationBar()
        
        self.photoCollectionView!.register(GalleryViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        reloadDisplay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadDisplay()
        setBackgroundImage()
    }
    
    func setNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.alpha = 0.4
    }
    
    func setBackgroundImage() {
        let image: UIImage = photoAlbum.showImages().lastObject as! UIImage
        self.backgroundImageView?.image = image
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.backgroundImageView?.addSubview(blurEffectView)
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
        
        cell.imageView.image = image
        
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let offset: CGFloat = 4
        let size = CGSize(width: self.view.frame.size.width - 2 * offset, height: 300)
        
        return size
    }
    
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: segueEditIdentifier, sender: self)
    }
 
    //MARK: Actions
    
    @IBAction func showCameracontroller (_ sender: UIBarButtonItem) {
        let cameraViewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CameraViewController") as UIViewController
        self.present(cameraViewController, animated: true, completion: nil)
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == segueEditIdentifier {
            let editViewController = segue.destination as! FiltersViewController
            let image = self.photosFromAlbum.object(at: selectedIndex) as! UIImage
            editViewController.currentImage = image
        }
    }
}
