//
//  TabBarViewModel.swift
//  Translate
//
//  Created by 정유진 on 2022/05/09.
//

import UIKit
import RxSwift
import RxCocoa
import CoreData

struct TabBarViewModel {
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate!.persistentContainer
    }()
    
    var translateViewModel = TranslateViewModel()
    var bookmarkViewModel = BookmarkViewModel()
    
    init() {
        translateViewModel.container = persistentContainer
        bookmarkViewModel.container = persistentContainer
    }
    
}
