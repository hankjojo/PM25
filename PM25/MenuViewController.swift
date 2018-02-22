//
//  MenuViewController.swift
//  TestAlamofire
//
//  Created by 江宗翰 on 2017/12/27.
//  Copyright © 2017年 Hank.Chiang. All rights reserved.
//

import UIKit
import Hero
class MenuViewController: UIViewController {
    var mod = "PM25"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hero_dismissViewController)))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
