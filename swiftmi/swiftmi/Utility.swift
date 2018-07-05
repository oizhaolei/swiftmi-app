//
//  Utility.swift
//  swiftmi
//
//  Created by yangyin on 15/4/21.
//  Copyright (c) 2015年 swiftmi. All rights reserved.
//

import UIKit


class Utility: NSObject {
   
    class func GetViewController<T>(_ controllerName:String)->T {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let toViewController = mainStoryboard.instantiateViewController(withIdentifier: controllerName) as! T
        return toViewController
        
    }
    
    class func formatDate(_ date:Date)->String {
    
        let fmt = DateFormatter()
         
        fmt.dateFormat = "yyyy-MM-dd"
        let dateString = fmt.string(from: date)
        return dateString
    }
    
    class func showMessage(_ parent:UIViewController, message:String) {
        let title = "提醒"
        Utility.showMessage(parent, title: title, message:message)
    }
    
    class func showMessage(_ parent:UIViewController, title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        alertController.addAction(okAction)

        parent.present(alertController, animated: true, completion: nil)
    }
    
    //SDKShare Show
    final class func share(_ parent:UIViewController,title:String,desc:String,imgUrl:String?,linkUrl:String) {
        
        var img = imgUrl
        if img == nil {
            img = "https://imgs.swiftmi.com/swiftmi180icon.png"
        }
        
        var text = desc;
        if text == "" {
            text = title;
        }
        
        let textWithUrl = "\(title) \(linkUrl)"
    
        let shareParams = NSMutableDictionary();
        
        shareParams.ssdkSetupShareParams(byText: text, images: [img!], url: URL(string: linkUrl), title: title, type: SSDKContentType.auto)
        
        shareParams.ssdkSetupWeChatParams(byText: text, title: title, url: URL(string:linkUrl), thumbImage: img, image: img, musicFileURL: nil, extInfo: nil, fileData: nil, emoticonData: nil, type: SSDKContentType.image, forPlatformSubType: SSDKPlatformType.typeWechat)
        
        shareParams.ssdkSetupCopyParams(byText: textWithUrl, images: nil, url:  URL(string: img!), type: SSDKContentType.text)
        shareParams.ssdkSetupSinaWeiboShareParams(byText: textWithUrl, title: textWithUrl, image:nil, url: URL(string:linkUrl), latitude: 0.0, longitude: 0.0, objectID: "", type: SSDKContentType.text)
        
        shareParams.ssdkSetupSMSParams(byText: textWithUrl, title: textWithUrl, images: nil, attachments: nil, recipients: nil, type: SSDKContentType.text)
        
        let items = [SSDKPlatformType.typeSinaWeibo.rawValue,SSDKPlatformType.typeWechat.rawValue,SSDKPlatformType.typeSMS.rawValue,SSDKPlatformType.typeCopy.rawValue];
        
        
        ShareSDK.showShareActionSheet(nil, items: items, shareParams: shareParams) { (state, type, userData, contentEntity, error, end:Bool) -> Void in
            switch(state) {
            case SSDKResponseState.success:
                Utility.showMessage(parent, title: "提示", message:"分享成功")
            case SSDKResponseState.fail:
                Utility.showMessage(parent, title: "提示", message:"分享失败：\(String(describing: error))")

            default:
                break;
            }
        }
        
     }
}
