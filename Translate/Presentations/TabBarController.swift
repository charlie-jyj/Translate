//
//  TabBarController.swift
//  Translate
//
//  Created by 정유진 on 2022/04/27.
//

import UIKit
import CoreData

class TabBarController: UITabBarController {
    
    let viewModel = CoreDataViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let translateViewController = TranslateViewController()
        let bookmarkViewController = BookmarkViewController(collectionViewLayout: UICollectionViewFlowLayout())
        translateViewController.bind(viewModel.translateViewModel)
        bookmarkViewController.bind(viewModel.bookmarkViewModel)
       
        translateViewController.tabBarItem = UITabBarItem(
            title: "번역",
            image: UIImage(systemName: "mic"),
            tag: 0)
        translateViewController.tabBarItem.selectedImage = UIImage(systemName: "mic.fill")
        bookmarkViewController.tabBarItem = UITabBarItem(
            title: "Bookmark",
            image: UIImage(systemName: "star"),
            tag: 1)
        bookmarkViewController.tabBarItem.selectedImage = UIImage(systemName: "star.fill")
       
        let viewControllers = [translateViewController, bookmarkViewController]
        setViewControllers(viewControllers, animated: true)
        
        tabBar.backgroundColor = .secondarySystemBackground
    }
    

}

