//
//  Utility.swift
//  swiftmi
//
//  Created by yangyin on 15/4/21.
//  Copyright (c) 2015年 swiftmi. All rights reserved.
//

import UIKit

class Utility: NSObject {
   
    class func GetViewController<T>(controllerName:String)->T {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let toViewController = mainStoryboard.instantiateViewControllerWithIdentifier(controllerName) as! T
        return toViewController
        
    }
    
    class func formatDate(date:NSDate)->String {
    
        let fmt = NSDateFormatter()
         
        fmt.dateFormat = "yyyy-MM-dd"
        let dateString = fmt.stringFromDate(date)
        return dateString
    }
    
    class func showMessage(msg:String) {
        
        let alert = UIAlertView(title: "提醒", message: msg, delegate: nil, cancelButtonTitle: "确定")
        alert.show()
    }
    
    //SDKShare Show
    final class func share(title:String,desc:String,imgUrl:String?,linkUrl:String) {
        
        var img = imgUrl
        if img == nil {
            img = "http://swiftmi.qiniudn.com/swiftmi180icon.png"
        }
        
        let imgAttach = ShareSDK.imageWithUrl(img)
        let content = "\(title) \(linkUrl)"
        
        
        
        let publishContent:ISSContent = ShareSDK.content(content, defaultContent:"Swift迷分享",image:nil, title:title,url:linkUrl,description:nil,mediaType:SSPublishContentMediaTypeNews)
        
        publishContent.addSinaWeiboUnitWithContent(content, image: nil)
        
        publishContent.addWeixinFavUnitWithType(2, content: content, title: title, url: linkUrl, thumbImage: nil, image: imgAttach, musicFileUrl: nil, extInfo: nil, fileData: nil, emoticonData: nil)
        
        publishContent.addWeixinSessionUnitWithType(2, content: content, title: title, url: linkUrl, thumbImage: nil, image: imgAttach, musicFileUrl: nil, extInfo: nil, fileData: nil, emoticonData: nil)
        
        publishContent.addWeixinTimelineUnitWithType(2, content: content, title: title, url: linkUrl, thumbImage: nil, image: imgAttach, musicFileUrl: nil, extInfo: nil, fileData: nil, emoticonData: nil)

        
        ShareSDK.showShareActionSheet(nil, shareList: nil, content: publishContent, statusBarTips: true, authOptions: nil, shareOptions: nil, result: {(type:ShareType,state:SSResponseState,statusInfo:ISSPlatformShareInfo!,error:ICMErrorInfo!,end:Bool) in
            // println(state.value)
            
            if (state.rawValue == SSResponseStateSuccess.rawValue){
                print("分享成功")
                let alert = UIAlertView(title: "提示", message:"分享成功", delegate:self, cancelButtonTitle: "ok")
                alert.show()
            }
            else {if (state.rawValue == 2) {
                let alert = UIAlertView(title: "提示", message:"您没有安装客户端，无法使用分享功能！", delegate:self, cancelButtonTitle: "ok")
                alert.show()
                // println(error.errorCode())
                  //println(error.errorDescription())
                  //println()
                }
            }
        })
    }
}
