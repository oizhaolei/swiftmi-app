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


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        Router.token = KeychainWrapper.stringForKey("token")
        UITabBar.appearance().tintColor = UIColor.themeBackgroundColor()
        UINavigationBar.appearance().barTintColor = UITabBar.appearance().tintColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().translucent = true
        UINavigationBar.appearance().barStyle = UIBarStyle.Black
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
         
        
        ShareSDK.registerApp("74dcfcc8d1d3", activePlatforms: [SSDKPlatformType.TypeCopy.rawValue, SSDKPlatformType.TypeSinaWeibo.rawValue,SSDKPlatformType.TypeWechat.rawValue,SSDKPlatformType.TypeSMS.rawValue], onImport: {
            
            (platformType:SSDKPlatformType) in
            
            switch(platformType) {
            case SSDKPlatformType.TypeSinaWeibo:
                ShareSDKConnector.connectWeibo(WeiboSDK.classForCoder())
           case SSDKPlatformType.TypeWechat:
                 ShareSDKConnector.connectWeChat(WXApi.classForCoder())
            default:
                break;
                
            }
            
            }, onConfiguration:{
                
                (platformType:SSDKPlatformType,appInfo:NSMutableDictionary!)  in
                
                switch(platformType) {
                    
                 case SSDKPlatformType.TypeSinaWeibo:
                    appInfo.SSDKSetupSinaWeiboByAppKey("568898243", appSecret: "38a4f8204cc784f81f9f0daaf31e02e3", redirectUri: "http://www.sharesdk.cn", authType: SSDKAuthTypeBoth)
                    
                 case SSDKPlatformType.TypeWechat:
                    appInfo.SSDKSetupWeChatByAppId("wx4868b35061f87885", appSecret: "64020361b8ec4c99936c0e3999a9f249")
                    
                default:
                    break;
                
                
                }
        })
        
        
         SplotlightHelper.AddItemToCoreSpotlight("0", title:"swift迷,专业的Swift开发者社区", contentDescription: "swift迷，致力于打造国内swift交流的地方，提供社区，文章,swift教程,swift源码等")
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        
    
        return true;
      //  return ShareSDK.handleOpenURL(url, wxDelegate: self)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return true;
       // return ShareSDK.handleOpenURL(url, sourceApplication: sourceApplication, annotation: annotation, wxDelegate: self)
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        if #available(iOS 9.0, *) {
            if userActivity.activityType == CSSearchableItemActionType {
                if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                    
                  
                   
                    let rootViewController = self.window!.rootViewController as! HomeTabBarController
                    
                    let nav = rootViewController.viewControllers![0]  as? UINavigationController
                    
                    if uniqueIdentifier.hasPrefix("article-")
                    {
                        
                        let postViewController:PostDetailController = Utility.GetViewController("PostDetailController")
                        
                         let startIndex = uniqueIdentifier.startIndex.advancedBy(8)
                        
                         postViewController.postId = Int(uniqueIdentifier.substringFromIndex(startIndex))
                        nav?.pushViewController(postViewController, animated: true)
                    }
                    else if uniqueIdentifier.hasPrefix("code-") {
                        
                        let codeDetail:CodeDetailViewController = Utility.GetViewController("CodeDetailViewController")
                        let startIndex = uniqueIdentifier.startIndex.advancedBy(5)
                        
                        codeDetail.codeId = Int(uniqueIdentifier.substringFromIndex(startIndex))
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

