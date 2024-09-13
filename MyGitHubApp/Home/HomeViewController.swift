//
//  HomeViewController.swift
//  MyGitHubApp
//
//  Created by tangmengyue on 2024/9/12.
//

import UIKit

class HomeViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let repositoryVC = RepositoryListViewController()
        repositoryVC.tabBarItem = UITabBarItem(title: "repository".L, image: UIImage(systemName: "folder"), selectedImage: UIImage(systemName: "folder.fill"))
        let profileVC = ProfileViewController()
        profileVC.tabBarItem = UITabBarItem(title: "my".L, image: UIImage(systemName: "person.circle"), selectedImage: UIImage(systemName: "person.circle.fill"))
        
        let repositoryNavVC = UINavigationController(rootViewController: repositoryVC)
        let profileNavVC = UINavigationController(rootViewController: profileVC)
        
        viewControllers = [repositoryNavVC, profileNavVC]
    }
}
