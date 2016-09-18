//
//  PostTableViewController.swift
//  swiftmi
//
//  Created by yangyin on 15/3/23.
//  Copyright (c) 2015year swiftmi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher


class PostTableViewController: UITableViewController {

    internal var data:[AnyObject] = [AnyObject]()
    
    var loading:Bool = false
    
    
    fileprivate func getDefaultData(){
    
        let dalPost = PostDal()
        
        let result = dalPost.getPostList()
        
        if result != nil {
            self.data = result!
            self.tableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     //   self.view.backgroundColor = UIColor.greenColor()
         self.tableView.estimatedRowHeight = 120;
        self.tableView.rowHeight = UITableViewAutomaticDimension
       
        
        //读取默认数据
        getDefaultData()
        
        self.tableView.addHeaderWithCallback{
            
            self.loadData(0, isPullRefresh: true)
        }
        
        self.tableView.addFooterWithCallback{
            
            if(self.data.count>0) {
                let  maxId = self.data.last!.value(forKey: "postId") as! Int
                self.loadData(maxId, isPullRefresh: false)
            }
        }
        
        self.tableView.headerBeginRefreshing()
       
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.data.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       //let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as! PostCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        
        let item: AnyObject = self.data[(indexPath as NSIndexPath).row]
        
        let commentCount = item.value(forKey: "viewCount") as? Int
        
        cell.commentCount.text = "\(commentCount!)"
        
        let pubTime = item.value(forKey: "createTime") as! Double
        let createDate = Date(timeIntervalSince1970: pubTime)
        
        cell.timeLabel.text = Utility.formatDate(createDate)
        
        //println(item.valueForKey("commentCount") as? Int)
        
        cell.title.text = item.value(forKey: "title") as? String
        cell.authorName.text = item.value(forKey: "authorName") as? String
        cell.channelName.text = item.value(forKey: "channelName") as? String
      
        if let avatar = item.value(forKey: "avatar") as? String {
            cell.avatar.kf.setImage(with: URL(string: avatar+"-a80")!, placeholder: nil)
        }
       
        
        
        cell.avatar.layer.cornerRadius = 5
        cell.avatar.layer.masksToBounds = true
       // cell.avatar.set
        // Configure the cell...
        cell.selectionStyle = .none;
        cell.updateConstraintsIfNeeded()
        // cell.contentView.backgroundColor = UIColor.grayColor()

       // cell.selectedBackgroundView = cell.containerView
        
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        cell.containerView.backgroundColor = UIColor(red: 0.85, green: 0.85, blue:0.85, alpha: 0.9)
    }
    

    
    var prototypeCell:PostCell?
    
    fileprivate func configureCell(_ cell:PostCell,indexPath: IndexPath,isForOffscreenUse:Bool){
        
        let item: AnyObject = self.data[(indexPath as NSIndexPath).row]
        cell.title.text = item.value(forKey: "title") as? String
        cell.channelName.text = item.value(forKey: "channelName") as? String
        cell.selectionStyle = .none;
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if prototypeCell == nil
        {
            self.prototypeCell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as? PostCell
        }
        
        self.configureCell(prototypeCell!, indexPath: indexPath, isForOffscreenUse: false)
        
        self.prototypeCell?.setNeedsUpdateConstraints()
        self.prototypeCell?.updateConstraintsIfNeeded()
        self.prototypeCell?.setNeedsLayout()
        self.prototypeCell?.layoutIfNeeded()
        
        
        let size = self.prototypeCell!.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
       
        return size.height;
        
    }
     
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == self.data.count-1 {
          
           // self.tableView.footerBeginRefreshing()
          //  loadData(self.data[indexPath.row].valueForKey("postId") as! Int,isPullRefresh:false)
            
        }
    }
    
    func loadData(_ maxId:Int,isPullRefresh:Bool){
        if self.loading {
            return
        }
        self.loading = true
        
      
       Alamofire.request(Router.topicList(maxId: maxId, count: 16)).responseJSON{
            closureResponse in
            
            self.loading = false
            
            if(isPullRefresh){
                self.tableView.headerEndRefreshing()
            }
            else{
                self.tableView.footerEndRefreshing()
            }
            if closureResponse.result.isFailure {
                let alert = UIAlertView(title: "网络异常", message: "请检查网络设置", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
                return
            }
            
            
            let json = closureResponse.result.value
            var result = JSON(json!)
            
            if result["isSuc"].boolValue {
                
                let items = result["result"].object as! [AnyObject]
               
                if(items.count==0){
                    return
                }
                
                if(isPullRefresh){
                    
                    

                    
                    let dalPost = PostDal()
                    dalPost.deleteAll()
                    
                    dalPost.addPostList(items)
                    
                    self.data.removeAll(keepingCapacity: false)
                }
                
                
                for  it in items {
                    
                    self.data.append(it);
                }
                DispatchQueue.main.async {
                   self.tableView.reloadData()
                }
               
                
                
            }
        }
    }
    
     /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    @IBAction func addTopic(_ sender: UIButton) {
    
        if KeychainWrapper.stringForKey("token") == nil {
           
            //未登录
            
            let loginController:LoginController = Utility.GetViewController("loginController")
            
            self.navigationController?.pushViewController(loginController, animated: true)
            
        }
    }
   
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
 
        if identifier == "toAddTopic" {
        
            if KeychainWrapper.stringForKey("token") == nil {
            
                //未登录
                return false
            }
        }
        return true
        
        
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "PostDetail" {
            
            if segue.destination is PostDetailController {
                let view = segue.destination as! PostDetailController
                let indexPath = self.tableView.indexPathForSelectedRow
                
                let article: AnyObject = self.data[(indexPath! as NSIndexPath).row]
                view.article = article
                
                
            }
        }
        
        
       
        
    }
    

}
