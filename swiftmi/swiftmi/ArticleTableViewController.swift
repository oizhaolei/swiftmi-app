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
                let maxId = self.data.last!.value(forKey: "articleId") as! Int
                self.loadData(maxId, isPullRefresh: false)
            }
        }
        
        self.tableView.headerBeginRefreshing()
    }
    
    fileprivate func getDefaultData(){
        
        let dalArticle = ArticleDal()
        let result = dalArticle.getList()
        if result != nil {
            self.data = result!
            self.tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        if let indexPath = tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: indexPath, animated: true)

        }
    }
    
    func loadData(_ maxId:Int,isPullRefresh:Bool) {
        if self.loading {
            return
        }
        self.loading = true
        
        Alamofire.request(Router.articleList(maxId: maxId, count: 12)).responseJSON {
            res in
            self.loading = false
            if(isPullRefresh){
                self.tableView.headerEndRefreshing()
            }
            else{
                self.tableView.footerEndRefreshing()
            }
            
            if res.result.isFailure {
                Utility.showMessage(self, title: "网络异常", message: "请检查网络设置")
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.data.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item: AnyObject = self.data[(indexPath as NSIndexPath).row]
        
        if let _ = item.value(forKey: "imageUrl") as? String {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "articleWithImageCell", for: indexPath) as! ArticleWithImageCell
            cell.loadData(item)
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! ArticleCell
            cell.loadData(item)
            return cell
        }
        
        // Configure the cell...

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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.destination is ArticleDetailController {
            let view = segue.destination as! ArticleDetailController
            let indexPath = self.tableView.indexPathForSelectedRow
            
            let article: AnyObject = self.data[(indexPath! as NSIndexPath).row]
            view.article = article
            view.articleId = article.value(forKey: "articleId") as? Int
            
            
        }
    }
    

}
