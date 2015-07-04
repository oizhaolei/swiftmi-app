//
//  LoginController.swift
//  swiftmi
//
//  Created by yangyin on 15/4/17.
//  Copyright (c) 2015年 swiftmi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class LoginController: UIViewController {

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    var loadingView:UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "登录"
        
        self.setView()
        // Do any additional setup after loading the view.
    }
    
    private func setView(){
    
        self.password.secureTextEntry = true 
        
    }

    private func showMsg(msg:String) {
        var alert = UIAlertView(title: "提醒", message: msg, delegate: nil, cancelButtonTitle: "确定")
        alert.show()
    }
    
    private func login() {
        
        if username.text.isEmpty {
            showMsg("用户名不能为空")
            return
        }
        if password.text.isEmpty || (password.text as NSString).length<6 {
            showMsg("密码不能为空且长度大于6位数")
            return
        }
        var loginname = username.text
        var loginpass = password.text
        
        let params = ["username":loginname,"password":loginpass]
        
        self.pleaseWait()
        
        self.loginBtn.enabled  = false
        self.loginBtn.setTitle("登录ing...", forState: UIControlState.allZeros)
        Alamofire.request(Router.UserLogin(parameters: params)).responseJSON{
            (_,_,json,error) in
            
            self.clearAllNotice()
            
            self.loginBtn.enabled  = true
            self.loginBtn.setTitle("登录", forState: UIControlState.allZeros)
            if error != nil {
                
                var alert = UIAlertView(title: "网络异常", message: "请检查网络设置", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
                return
            }
            
            
            
            var result = JSON(json!)
            
            if result["isSuc"].boolValue {
                
                var user = result["result"]
                
                var token = user["token"].stringValue
                
                KeychainWrapper.setString(token, forKey: "token")
                Router.token  = token
              
                var dalUser = UsersDal()
                
                dalUser.deleteAll()
                var currentUser  =  dalUser.addUser(user, save: true)
                
                self.goToBackView(currentUser!)
                
            } else {
                
                var errMsg = result["msg"].stringValue
                var alert = UIAlertView(title: "登录失败", message: "\(errMsg)", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            }
        }
        
    }
    @IBAction func userLogin(sender: UIButton) {
        login()
        
    }
    
    
    @IBAction func regAction(sender: AnyObject) {
        
        var toViewController:RegisterController = Utility.GetViewController("registerController")
        
        self.navigationController?.pushViewController(toViewController, animated: true)
    }
    
    private func goToBackView(user:Users) {
        
        var desController = self.navigationController?.popViewControllerAnimated(true)
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
