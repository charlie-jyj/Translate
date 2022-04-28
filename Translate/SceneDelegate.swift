//
//  SceneDelegate.swift
//  Translate
//
//  Created by 정유진 on 2022/04/27.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = .systemBackground
        window?.tintColor = UIColor.mainTintColor
        window?.rootViewController = TabBarController()
        window?.makeKeyAndVisible()
    }
}

