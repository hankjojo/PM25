//
//  TestViewController.swift
//  TestAlamofire
//
//  Created by 江宗翰 on 2017/12/26.
//  Copyright © 2017年 Hank.Chiang. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // 初始建立 NVActivityIndicatorView
        let activityView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150), type: .orbit, color: .black)
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        // 啟動 NVActivityIndicatorView 動畫
        activityView.startAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
