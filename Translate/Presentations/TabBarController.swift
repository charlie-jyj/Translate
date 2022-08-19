//
//  TabBarController.swift
//  Translate
//
//  Created by 정유진 on 2022/04/27.
//

import UIKit
import CoreData
import RxSwift

class TabBarController: UITabBarController {
    
    let viewModel = CoreDataViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tabBar.frame.size.height = 100
        tabBar.frame.origin.y = view.frame.height - 100
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let translateViewController = TranslateViewController()
        let bookmarkViewController = BookmarkViewController(collectionViewLayout: UICollectionViewFlowLayout())
        translateViewController.bind(viewModel.translateViewModel)
        bookmarkViewController.bind(viewModel.bookmarkViewModel)
        
        Observable.just(true)
            .bind(to: viewModel.viewdidload)
            .disposed(by: disposeBag)
       
        translateViewController.tabBarItem = UITabBarItem(
            title: "번역",
            image: UIImage(systemName: "character"),
            tag: 0)
        translateViewController.tabBarItem.selectedImage = UIImage(systemName: "character.cursor.ibeam")
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

