//
//  AppDelegate.swift
//  
//
//  Created by yangyin on 15/4/10.
//  Copyright (c) 2015年 swiftmi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        Router.token = KeychainWrapper.stringForKey("token")
        
        ShareSDK.registerApp("74dcfcc8d1d3")
        //新浪微博
        ShareSDK.connectSinaWeiboWithAppKey("3314374338", appSecret: "988b7cb3d34a994aa758b80e5097c3cb", redirectUri: "https://api.weibo.com/oauth2/default.html",weiboSDKCls:WeiboSDK.classForCoder())
        
        //链接微信
        ShareSDK.connectWeChatWithAppId("wxaae8ddda9c357129",appSecret:"20dfc209d79def9c19bbc640a85ead2a", wechatCls: WXApi.classForCoder())
        //微信好友
        ShareSDK.connectWeChatSessionWithAppId("wxaae8ddda9c357129",appSecret:"20dfc209d79def9c19bbc640a85ead2a", wechatCls:WXApi.classForCoder())
        //微信朋友圈
        ShareSDK.connectWeChatTimelineWithAppId("wxaae8ddda9c357129",appSecret:"20dfc209d79def9c19bbc640a85ead2a", wechatCls: WXApi.classForCoder())
        
        ShareSDK.connectSMS()
        ShareSDK.connectCopy()
        
        
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
        return ShareSDK.handleOpenURL(url, wxDelegate: self)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return ShareSDK.handleOpenURL(url, sourceApplication: sourceApplication, annotation: annotation, wxDelegate: self)
    }


}

