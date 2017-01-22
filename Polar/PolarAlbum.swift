//
//  PolarAlbum.swift
//  Polar
//
//  Created by Игорь Талов on 21.01.17.
//  Copyright © 2017 Игорь Талов. All rights reserved.
//

import UIKit
import Photos

class PolarAlbum: NSObject {

    static let customAlbumName = "Polar"
    
    var assetCollection: PHAssetCollection!
    var albumFound: Bool = false
    var collection: PHAssetCollection!
    var assetCollectionPlaceHolder: PHObjectPlaceholder!
    var photoAsset: PHFetchResult<AnyObject>!
    
    override init() {
        super.init()
        
        createAlbum()
    }
    
    func createAlbum() {
        //Get Fetch Options
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", PolarAlbum.customAlbumName)
        let collection : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        //Check return value - If found, then get the first album out
        if let _:AnyObject = collection.firstObject {
            self.albumFound = true
            self.assetCollection = collection.firstObject as PHAssetCollection!
        } else {
            //If not found - Then create a new album
            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: PolarAlbum.customAlbumName)
                self.assetCollectionPlaceHolder = createAlbumRequest.placeholderForCreatedAssetCollection
            }, completionHandler: { (success, error) in
                self.albumFound = success
                
                if (success) {
                    let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [self.assetCollectionPlaceHolder.localIdentifier], options: nil)
                    print(collectionFetchResult)
                    self.assetCollection = collectionFetchResult.firstObject as PHAssetCollection!
                }
            })
        }
    }
    
    func saveImage(image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceholder = assetRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            let enumeration: NSArray = [assetPlaceholder!]
            albumChangeRequest?.addAssets(enumeration)
        }) { (success, error) in
            
            if success {
                print("photo added to album")
            } else if error != nil {
                print("error")
            }
        }
        
    }
}
