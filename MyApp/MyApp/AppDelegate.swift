//
//  AppDelegate.swift
//  MyApp
//
//  Created by 曹世鑫 on 2020/3/4.
//  Copyright © 2020 曹世鑫. All rights reserved.
//

import UIKit
import Flutter
import FlutterPluginRegistrant

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {

//    var window: UIWindow?
    lazy var flutterEngine = FlutterEngine(name: "")
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        flutterEngine.run();
        GeneratedPluginRegistrant.register(with: self.flutterEngine);
        
        self.window?.rootViewController = UINavigationController.init(rootViewController: ViewController())
        self.window?.backgroundColor = .white
        self.window?.makeKeyAndVisible()
        //        return true
        return super.application(application, didFinishLaunchingWithOptions: launchOptions);
    }
}


