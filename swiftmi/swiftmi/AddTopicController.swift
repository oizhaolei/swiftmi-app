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
    
    @IBAction func publishClick(_ sender: AnyObject) {
        
        let title = self.titleField.text
        let content = self.contentField.text
        
        if title!.isEmpty {
            Utility.showMessage("标题不能为空!")
            return
            
        }
        
        if (content?.isEmpty)! {
            Utility.showMessage("内容不能为空!")
            return
            
        }
        
        if title != nil {
            
            let btn = sender as! UIButton
            
            btn.isEnabled = false
          
            let params:[String:AnyObject] = ["title":title! as AnyObject,"content":content! as AnyObject,"channelId":1 as AnyObject]
            
            
            Alamofire.request(Router.topicCreate(parameters: params)).responseJSON{
                closureResponse in
                
            
                
                 btn.isEnabled = true 
                if closureResponse.result.isFailure {
                    
                    let alert = UIAlertView(title: "网络异常", message: "请检查网络设置", delegate: nil, cancelButtonTitle: "确定")
                    alert.show()
                    return
                }
                
                let json = closureResponse.result.value
                
                
                
                var result = JSON(json!)
                
                if result["isSuc"].boolValue {
                    
                   self.navigationController?.popViewController(animated: true)
                    
                    
                } else {
                    
                    let errMsg = result["msg"].stringValue
                    Utility.showMessage("发布失败!:\(errMsg)")
                }
            }
        }
        
    }
    fileprivate func setView() {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: titleField.frame.size.height - width, width:  titleField.frame.size.width,height: width)

        border.borderWidth = width
        titleField.layer.addSublayer(border)
       titleField.layer.masksToBounds = true
        
        
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(AddTopicController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(AddTopicController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func keyboardWillShow(_ notification: Notification) {
        let info:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        
        
        let duration = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let endKeyboardRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        
        
        
        
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(), animations: {
         
            
            for constraint in self.view.constraints {
                
              
                let cons = constraint as NSLayoutConstraint
                
                if let _ = cons.secondItem as? UITextView
                {
                    
                    if cons.secondAttribute == NSLayoutAttribute.bottom {
                        
                        
                        cons.constant = 10 + endKeyboardRect.height
                        
                        
                        
                        break;
                    }
                    
                }
               
            }
          
            }, completion: nil)
    }

    func keyboardWillHide(_ notification: Notification) {
        let info:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        
        
        let duration = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        
        
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(),
            animations: {
            
                for constraint in self.view.constraints {
                
                
                let cons = constraint as NSLayoutConstraint
                
                if let _ = cons.secondItem as? UITextView
                {
                    
                    if cons.secondAttribute == NSLayoutAttribute.bottom {
                        
                        
                        cons.constant = 10
                        
                        
                        
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
