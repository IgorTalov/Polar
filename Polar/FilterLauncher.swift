//
//  FilterLauncher.swift
//  Polar
//
//  Created by Игорь Талов on 28.05.17.
//  Copyright © 2017 Игорь Талов. All rights reserved.
//

import UIKit

class FilterLauncher: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let cellID = "cellID"
    
    let cellWidth: CGFloat = 80
    let cellHeght: CGFloat = 100
    let launcherHeight: CGFloat = 180
    var editController: EditViewController?
    
    let filtersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = UIColor.clear
        return cv
    }()
    
    override init() {
        super.init()
        filtersCollectionView.dataSource = self
        filtersCollectionView.delegate = self
        filtersCollectionView.showsVerticalScrollIndicator = false
        filtersCollectionView.register(FilterCell.self, forCellWithReuseIdentifier: cellID)
    }
    
    //MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! FilterCell

        cell.titleLabel.backgroundColor = UIColor.purple
        
        return cell
    }
    
    //MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Filter")
    }
    
    //MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeght)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    // Show and Hide Launcher
    func showLauncher() {
        if let window = UIApplication.shared.keyWindow {
        window.addSubview(filtersCollectionView)
        
        let y = window.frame.height - launcherHeight
            
        filtersCollectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: launcherHeight)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.filtersCollectionView.frame = CGRect(x: 0, y: y, width: self.filtersCollectionView.frame.width, height: self.filtersCollectionView.frame.height)
        }, completion: { (finish) in
            
            })
        }
    }
    
    func dismissMenu() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            if let window = UIApplication.shared.keyWindow {
                self.filtersCollectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.filtersCollectionView.frame.width, height: self.filtersCollectionView.frame.height)
            }
            
        }) { (complition) in
            
        }
    }
    
}

class FilterCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.image = UIImage(named: "paris")
        imgView.contentMode = .scaleToFill
        return imgView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.orange
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 10)
        label.text = "Filter"
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(imageView)
        addSubview(titleLabel)
        
        addConstraintsWithFormat(format: "H:|[v0(80)]|", views: imageView)
        addConstraintsWithFormat(format: "H:|[v0(80)]|", views: titleLabel)
        addConstraintsWithFormat(format: "V:|[v0(80)]-1-[v1(20)]", views: imageView, titleLabel)
    }
    
}
