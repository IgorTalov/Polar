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
    @IBOutlet weak var tabBarView: UIView?
    
    
    var photoAlbum = PolarAlbum()
    var photosFromAlbum = NSMutableArray()
    var selectedIndex: Int = 0
    var selectedImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.lightGray
        setNavigationBar()
        setTabBarView()
        
        self.photoCollectionView!.register(GalleryViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        reloadDisplay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadDisplay()
        setBackgroundImage()
    }
    
    func setTabBarView() {
        self.tabBarView?.backgroundColor = UIColor.black
        self.tabBarView?.layer.opacity = 0.8
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
    }

    // MARK: UICollectionViewDataSource

     func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosFromAlbum.count
    }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GalleryViewCell
    
        let image = self.photosFromAlbum.object(at: indexPath.row) as! UIImage
        
        cell.imageView.image = image
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedImage = self.photosFromAlbum.object(at: indexPath.row) as? UIImage
        
        let cell = collectionView.cellForItem(at: indexPath) as! GalleryViewCell
        
        if cell.isSelected == true {
            cell.isSelected = false
            cell.layer.borderColor = UIColor.yellow.cgColor
            cell.layer.borderWidth = 3.0
        } else {
            cell.isSelected = true
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.layer.borderWidth = 3.0
        }
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
