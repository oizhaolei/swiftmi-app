//
//  AddTopicController.swift
//  swiftmi
//
//  Created by yangyin on 15/4/23.
//  Copyright (c) 2015年 swiftmi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class AddTopicController: UIViewController {

    @IBOutlet weak var contentField: UITextView!
    @IBOutlet weak var titleField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setView()
        
    }
    
    @IBAction func publishClick(sender: AnyObject) {
        
        var title = self.titleField.text
        var content = self.contentField.text
        
        if title.isEmpty {
            Utility.showMessage("标题不能为空!")
            return
            
        }
        
        if content.isEmpty {
            Utility.showMessage("内容不能为空!")
            return
            
        }
        
        if title != nil {
            
            var btn = sender as! UIButton
            
            btn.enabled = false
          
            let params:[String:AnyObject] = ["title":title,"content":content,"channelId":1]
            
            
            Alamofire.request(Router.TopicCreate(parameters: params)).responseJSON{
                (_,_,json,error) in
                
                 btn.enabled = true 
                if error != nil {
                    
                    var alert = UIAlertView(title: "网络异常", message: "请检查网络设置", delegate: nil, cancelButtonTitle: "确定")
                    alert.show()
                    return
                }
                
                
                
                var result = JSON(json!)
                
                if result["isSuc"].boolValue {
                    
                   self.navigationController?.popViewControllerAnimated(true)
                    
                    
                } else {
                    
                    var errMsg = result["msg"].stringValue
                    Utility.showMessage("发布失败!:\(errMsg)")
                }
            }
        }
        
    }
    private func setView() {
        var border = CALayer()
        var width = CGFloat(1.0)
        border.borderColor = UIColor.lightGrayColor().CGColor
        border.frame = CGRect(x: 0, y: titleField.frame.size.height - width, width:  titleField.frame.size.width,height: width)

        border.borderWidth = width
        titleField.layer.addSublayer(border)
       titleField.layer.masksToBounds = true
        
        
        var center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info:NSDictionary = notification.userInfo!
        
        
        let duration = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        var beginKeyboardRect = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        var endKeyboardRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        
        
        
        var yOffset = endKeyboardRect.origin.y - beginKeyboardRect.origin.y
        
        
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
         
            
            for constraint in self.view.constraints() {
                
              
                var cons = constraint as? NSLayoutConstraint
                
                if let view = cons!.secondItem as? UITextView
                {
                    
                    if cons!.secondAttribute == NSLayoutAttribute.Bottom {
                        
                        
                        cons!.constant = 10 + endKeyboardRect.height
                        
                        
                        
                        break;
                    }
                    
                }
               
            }
          
            }, completion: nil)
    }

    func keyboardWillHide(notification: NSNotification) {
        var info:NSDictionary = notification.userInfo!
        var keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        var keyboardHeight:CGFloat = keyboardSize.height
        
        let duration = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        
        
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {
            
                for constraint in self.view.constraints() {
                
                
                var cons = constraint as? NSLayoutConstraint
                
                if let view = cons!.secondItem as? UITextView
                {
                    
                    if cons!.secondAttribute == NSLayoutAttribute.Bottom {
                        
                        
                        cons!.constant = 10
                        
                        
                        
                        break;
                    }
                    
                }
                
            }
        
            
            }, completion: nil)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
