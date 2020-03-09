//
//  ViewController.swift
//  MyApp
//
//  Created by 曹世鑫 on 2020/3/4.
//  Copyright © 2020 曹世鑫. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "原生页面"
               
        let btn: UIButton = UIButton()
        btn.backgroundColor = .cyan
        btn.frame = CGRect(x: 50, y: 100, width: 100, height: 50)
        btn.addTarget(self, action: #selector(btnChoose), for: .touchUpInside)
        self.view.addSubview(btn);
        
    }
    
    @objc func btnChoose() {
        let flutterEngine = (UIApplication.shared.delegate as! AppDelegate).flutterEngine
        let flutterViewController = SecondViewController(engine: flutterEngine, channelName: "tech.brainco.focusgame/router", method: "navigate", arguments: ["path":"ROCKET_GAME","data":["duration":30]])
        
        //游戏模块使用导航的话需要添加触发方法，来控制导航的返回。目前用模态弹出，flutter是会操作关闭的。
//        self.navigationController?.pushViewController(flutterViewController, animated: true)
        present(flutterViewController, animated: true, completion: nil)
    }

}

