//
//  AppDelegate.swift
//  
//
//  Created by yangyin on 15/4/10.
//  Copyright (c) 2015年 swiftmi. All rights reserved.
//

import UIKit
import CoreSpotlight
import SwiftyJSON


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Router.token = KeychainWrapper.stringForKey("token")
        UITabBar.appearance().tintColor = UIColor.themeBackgroundColor()
        UINavigationBar.appearance().barTintColor = UITabBar.appearance().tintColor
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().barStyle = UIBarStyle.black
        //UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
         
        
        ShareSDK.registerApp("74dcfcc8d1d3", activePlatforms: [SSDKPlatformType.typeCopy.rawValue, SSDKPlatformType.typeSinaWeibo.rawValue,SSDKPlatformType.typeWechat.rawValue,SSDKPlatformType.typeSMS.rawValue], onImport: {
            
            (platformType:SSDKPlatformType) in
            
            switch(platformType) {
//            case SSDKPlatformType.typeSinaWeibo:
//                ShareSDKConnector.connectWeibo(WeiboSDK.classForCoder())
           case SSDKPlatformType.typeWechat:
                 ShareSDKConnector.connectWeChat(WXApi.classForCoder())
            default:
                break;
                
            }
            
            }, onConfiguration:{
                
                (platformType,appInfo)  in
                
                switch(platformType) {
                    
                 case SSDKPlatformType.typeSinaWeibo:
                    appInfo?.ssdkSetupSinaWeibo(byAppKey: "3314374338", appSecret: "988b7cb3d34a994aa758b80e5097c3cb", redirectUri: "https://api.weibo.com/oauth2/default.html", authType: SSDKAuthTypeBoth)
                    
                 case SSDKPlatformType.typeWechat:
                    appInfo?.ssdkSetupWeChat(byAppId: "wxaae8ddda9c357129", appSecret: "20dfc209d79def9c19bbc640a85ead2a")
                    
                default:
                    break;
                
                
                }
        })
        
        
         SplotlightHelper.AddItemToCoreSpotlight("0", title:"swift迷,专业的Swift开发者社区", contentDescription: "swift迷，致力于打造国内swift交流的地方，提供社区，文章,swift教程,swift源码等")
        UIApplication.shared.applicationIconBadgeNumber = 0;

        Thread.sleep(forTimeInterval: 1)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        
    
        return true;
      //  return ShareSDK.handleOpenURL(url, wxDelegate: self)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return true;
       // return ShareSDK.handleOpenURL(url, sourceApplication: sourceApplication, annotation: annotation, wxDelegate: self)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if #available(iOS 9.0, *) {
            if userActivity.activityType == CSSearchableItemActionType {
                if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                    
                  
                   
                    let rootViewController = self.window!.rootViewController as! HomeTabBarController
                    
                    let nav = rootViewController.viewControllers![0]  as? UINavigationController
                    
                    if uniqueIdentifier.hasPrefix("article-")
                    {
                        
                        let postViewController:PostDetailController = Utility.GetViewController("PostDetailController")
                        
                         let startIndex = uniqueIdentifier.index(uniqueIdentifier.startIndex, offsetBy: 8)
                        
                         postViewController.postId = Int(uniqueIdentifier[startIndex...])
                        nav?.pushViewController(postViewController, animated: true)
                    }
                    else if uniqueIdentifier.hasPrefix("code-") {
                        
                        let codeDetail:CodeDetailViewController = Utility.GetViewController("CodeDetailViewController")
                        let startIndex = uniqueIdentifier.index(uniqueIdentifier.startIndex, offsetBy: 5)
                        
                        codeDetail.codeId = Int(uniqueIdentifier[startIndex...])
                        nav?.pushViewController(codeDetail, animated: true)
                    }
                
                }
            }
        } else {
            // Fallback on earlier versions
        }
        return true
    }


}

