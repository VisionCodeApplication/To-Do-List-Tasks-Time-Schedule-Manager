//
//  SplashVC.swift
//  TaskManager
//
//  Created by iMac on 22/10/21.
//  Copyright © 2021 Hima. All rights reserved.
//

import UIKit
import Lottie
import ImageIO

class SplashVC: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        var Timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(timer), userInfo: nil, repeats: false)

    }
    @objc func timer(){
        let initialViewController = storyboard?.instantiateViewController(withIdentifier: "TabBarID") as! UITabBarController
       for tabBarItem in initialViewController.tabBar.items! {
            tabBarItem.title = ""
            tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
        initialViewController.selectedIndex = 0
        navigationController?.pushViewController(initialViewController, animated: true)
    }
    
}
