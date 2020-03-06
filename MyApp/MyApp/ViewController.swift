//
//  ViewController.swift
//  MyApp
//
//  Created by 曹世鑫 on 2020/3/4.
//  Copyright © 2020 曹世鑫. All rights reserved.
//

import UIKit
import Flutter
import FlutterPluginRegistrant

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
        let flutterEngine = FlutterEngine(name: "")
        flutterEngine.run()
        GeneratedPluginRegistrant.register(with: flutterEngine);
//        let flutterEngine = (UIApplication.shared.delegate as! AppDelegate).flutterEngine
        let flutterController =
            SecondViewController.init(engine: flutterEngine, nibName: nil, bundle: nil)
        flutterController.channelMethodArguments = ["navigate":["path":"ROCKET_GAME","data":["duration":30]]]
        flutterController.channelName = "tech.brainco.focusgame/router"
//        flutterController.pushRoute("ROCKET_GAME")
        self.navigationController?.pushViewController(flutterController, animated: true)
    }

}

