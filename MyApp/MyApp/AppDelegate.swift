//
//  AppDelegate.swift
//  MyApp
//
//  Created by 曹世鑫 on 2020/3/4.
//  Copyright © 2020 曹世鑫. All rights reserved.
//

import UIKit
import FlutterPluginRegistrant
import Flutter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    lazy var flutterEngine = FlutterEngine(name: "com.brainco.gameEngine")
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window?.rootViewController = UINavigationController.init(rootViewController: ViewController())
        self.window?.backgroundColor = .white
        self.window?.makeKeyAndVisible()
        initEngine()
        
        return true
    }
    
    private func initEngine() {
        //这个要在跳转方法之前运行环境，也可以在appdelegate里面启动就初始化，环境运行需要时间，单写在跳转方法里面靠前位置是不可以的。
        flutterEngine.run();
        GeneratedPluginRegistrant.register(with: flutterEngine);
    }
    
    
}


