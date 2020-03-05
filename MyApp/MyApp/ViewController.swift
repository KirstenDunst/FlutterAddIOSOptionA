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
        let flutterEngine = (UIApplication.shared.delegate as! AppDelegate).flutterEngine
        let flutterController =
            SecondViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        flutterController.pushRoute("ROCKET_GAME")
//        let channelName = "tech.brainco.focusgame/router"
//        let messageChannel = FlutterMethodChannel.init(name: channelName, binaryMessenger: flutterController.binaryMessenger)
//        messageChannel.invokeMethod("navigate", arguments: ["path":"ROCKET_GAME","data":["duration":30]])
        self.navigationController?.pushViewController(flutterController, animated: true)
    }

}

