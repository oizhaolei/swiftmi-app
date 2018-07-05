//
//  MyController.swift
//  swiftmi
//
//  Created by yangyin on 15/4/14.
//  Copyright (c) 2015年 swiftmi. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import SwiftyJSON

class MyController: UITableViewController {

    
    
    var profileHeaderView:ProfileHeaderView?
    
    var currentUser:Users?
    
    @IBOutlet weak var logoutCell: UITableViewCell!
   
    @IBOutlet weak var signatureLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    override func viewDidAppear(_ animated: Bool) {
        
        loadCurrentUser()
        self.clearAllNotice()
    }
    
    fileprivate func loadCurrentUser() {
        
        
       
        if currentUser == nil {
            
            let token = KeychainWrapper.stringForKey("token")
            
            if token != nil {
                
                let dalUser = UsersDal()
                currentUser = dalUser.getCurrentUser()
            }
            
            if currentUser != nil {
                
                
                self.profileHeaderView?.setData(self.currentUser!)
                self.emailLabel.text = self.currentUser?.email
                self.signatureLabel.text = self.currentUser?.signature
                
                 self.logoutCell.isHidden = false
                
            }else {
                 self.logoutCell.isHidden = true
            }
        }
        
        
       
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setView()
      
    }
    
    
    
    

    func setView() {
        
        self.profileHeaderView = ProfileHeaderView.viewFromNib()!
        self.profileHeaderView?.frame = CGRect(x: 0,y: 0,width: self.view.frame.width,height: 280);
        self.tableView.tableHeaderView = self.profileHeaderView!
        self.profileHeaderView?.tapLoginCallBack = {
            
            let toViewController:LoginController =  Utility.GetViewController("loginController")
            self.navigationController?.pushViewController(toViewController, animated: true)
        
            return true
        }
        
    }
    
    fileprivate func logout() {
        
        if KeychainWrapper.hasValueForKey("token") {
            _ = KeychainWrapper.removeObjectForKey("token")
            self.currentUser = nil
            Router.token = ""
            
        }
        self.emailLabel.text = ""
        self.signatureLabel.text = ""
        self.profileHeaderView?.resetData()
        self.tableView.reloadData()
        
        
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.profileHeaderView?.scrollViewDidScroll(scrollView)
   
    }

   
  
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 0 {
        
            self.logout()
        }
        else if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 {
            
            let url = URL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=993402332")
            UIApplication.shared.open(url!)
            //self.logout()
            /*
            var webViewController:WebViewController = Utility.GetViewController("webViewController")
            webViewController.webUrl = "http://www.swiftmi.com/timeline"
            webViewController.title = " 关于Swift迷 "
            webViewController.isPop = true
            self.navigationController?.pushViewController(webViewController, animated: true)*/
            
        }
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
