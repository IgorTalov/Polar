//
//  EditViewController.swift
//  Polar
//
//  Created by Игорь Талов on 28.05.17.
//  Copyright © 2017 Игорь Талов. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {
    
    lazy var menuFilterBar: MenuBar = {
        let menuView = MenuBar()
        menuView.editController = self
        return menuView
    }()

    lazy var filterLauncher: FilterLauncher = {
        let launcher = FilterLauncher()
        launcher.editController = self
        return launcher
    }()
    
    let imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.image = UIImage(named: "paris")
        return imgView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupMenuBar()
    }
    
    func setupViews() {
        view.addSubview(imageView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: imageView)
        view.addConstraintsWithFormat(format: "V:|[v0(320)]", views: imageView)
    }
    
    func setupMenuBar() {
        view.addSubview(menuFilterBar)

        view.addConstraintsWithFormat(format: "H:|[v0]|", views: menuFilterBar)
        view.addConstraintsWithFormat(format: "V:[v0(50)]", views: menuFilterBar)
        
        menuFilterBar.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
    }
    
    //Show Launcher
    
    func showLauncherByIndexPath(indexPath: IndexPath) {
        
        let index: NSInteger = indexPath.row
        
        if index == 1 {
            filterLauncher.showLauncher()
        } else if index == 2 {
            
        }

    }
}
