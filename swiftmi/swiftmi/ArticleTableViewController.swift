//
//  ArticleTableViewController.swift
//  swiftmi
//
//  Created by yangyin on 16/2/3.
//  Copyright © 2016年 swiftmi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class ArticleTableViewController: UITableViewController {

    internal var data:[AnyObject] = [AnyObject]()
    var loading:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 120;
        self.tableView.rowHeight = UITableViewAutomaticDimension
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        getDefaultData();
        
        self.tableView.addHeaderWithCallback{
            
            self.loadData(0, isPullRefresh: true)
        }
        
        self.tableView.addFooterWithCallback{
            
            if(self.data.count>0) {
                let maxId = self.data.last!.valueForKey("articleId") as! Int
                self.loadData(maxId, isPullRefresh: false)
            }
        }
        
        self.tableView.headerBeginRefreshing()
    }
    
    private func getDefaultData(){
        
        let dalArticle = ArticleDal()
        let result = dalArticle.getList()
        if result != nil {
            self.data = result!
            self.tableView.reloadData()
        }
    }

    
    
    func loadData(maxId:Int,isPullRefresh:Bool) {
        if self.loading {
            return
        }
        self.loading = true
        
        Alamofire.request(Router.ArticleList(maxId: maxId, count: 12)).responseJSON {
            res in
            self.loading = false
            if(isPullRefresh){
                self.tableView.headerEndRefreshing()
            }
            else{
                self.tableView.footerEndRefreshing()
            }
            
            if res.result.isFailure {
                let alert = UIAlertView(title: "网络异常", message: "请检查网络设置", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
                return
            }
             
            let json = res.result.value
            let result = JSON(json!)
            if result["isSuc"].boolValue {
                
                let items = result["result"].object as! [AnyObject]

                if(items.count==0){
                    return
                }
                
                if(isPullRefresh){
                    
                    let articleDal = ArticleDal()
                    articleDal.deleteAll()
                    
                    articleDal.addList(items)
                    
                    self.data.removeAll(keepCapacity: false)
                }
                
                for  it in items {
                    
                    self.data.append(it);
                }
                dispatch_async(dispatch_get_main_queue()) {
                    
                    
                    self.tableView.reloadData()
                }
            }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.data.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let item: AnyObject = self.data[indexPath.row]
        
        if let _ = item.valueForKey("imageUrl") as? String {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("articleWithImageCell", forIndexPath: indexPath) as! ArticleWithImageCell
            cell.loadData(item)
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("articleCell", forIndexPath: indexPath) as! ArticleCell
            cell.loadData(item)
            return cell
        }
        
        // Configure the cell...

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
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
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.destinationViewController is ArticleDetailController {
            let view = segue.destinationViewController as! ArticleDetailController
            let indexPath = self.tableView.indexPathForSelectedRow
            
            let article: AnyObject = self.data[indexPath!.row]
            view.article = article
            view.articleId = article.valueForKey("articleId") as? Int
            
            
        }
    }
    

}
