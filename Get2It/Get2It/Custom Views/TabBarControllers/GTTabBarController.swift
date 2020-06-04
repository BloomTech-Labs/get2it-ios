//
//  GTTabBarController.swift
//  Get2It
//
//  Created by John Kouris on 3/28/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import UIKit

class GTTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBar.appearance().tintColor = .systemBlue
        viewControllers = [createHomeNC(), createTimerNC()]
    }
    
    func createHomeNC() -> UINavigationController {
        let homeVC = HomeVC()
        homeVC.title = "Home"
        homeVC.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 0)
        
        return UINavigationController(rootViewController: homeVC)
    }
    
    func createTimerNC() -> UINavigationController {
        let timerVC = TimerVC()
        timerVC.title = "Timer"
        timerVC.tabBarItem = UITabBarItem(tabBarSystemItem: .mostRecent, tag: 1)
        
        return UINavigationController(rootViewController: timerVC)
    }
    
}
