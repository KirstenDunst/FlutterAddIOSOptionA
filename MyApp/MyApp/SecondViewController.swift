//
//  SecondViewController.swift
//  MyApp
//
//  Created by 曹世鑫 on 2020/3/4.
//  Copyright © 2020 曹世鑫. All rights reserved.
//

import UIKit
import Flutter

class SecondViewController: FlutterViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Flutter页面"
        // 要与main.dart中一致
        let channelName = "tech.brainco.focusgame/router"
        let messageChannel = FlutterMethodChannel.init(name: channelName, binaryMessenger: self.binaryMessenger)
        messageChannel.invokeMethod("navigate", arguments: ["path":"ROCKET_GAME","data":["duration":30]])
        
        messageChannel.setMethodCallHandler {[weak self] (call, result) in
            guard let strongSelf = self else { return }
            // call.method 获取 flutter 给回到的方法名，要匹配到 channelName 对应的多个 发送方法名，一般需要判断区分
            // call.arguments 获取到 flutter 给到的参数，（比如跳转到另一个页面所需要参数）
            // result 是给flutter的回调， 该回调只能使用一次
            print("flutter 给到我 method:\(call.method) arguments:\(String(describing: call.arguments))")
            strongSelf.navigationController?.popViewController(animated: true)
        }
        
        
    }

}


     
