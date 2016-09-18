//
//  BookViewController.swift
//  swiftmi
//
//  Created by yangyin on 15/4/2.
//  Copyright (c) 2015年 swiftmi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class BookViewController: UITableViewController {


    @IBOutlet weak var bookType: UISegmentedControl!
    internal var data:[AnyObject] = [AnyObject]()
    
    
    internal var data2:[AnyObject] = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 120;
         
        self.tableView.addHeaderWithCallback{
            
            self.loadData(self.GetBookType(),maxId:0, isPullRefresh: true)
        }
        
        self.tableView.addFooterWithCallback{
            
            if(self.data.count>0) {
                let  maxId = self.data.last!.value(forKey: "bookId") as! Int
                self.loadData(self.GetBookType(),maxId:maxId, isPullRefresh: false)
            }
        }
        
        self.tableView.headerBeginRefreshing()
        

        
    }
    
    
    fileprivate func getBookData(_ row:Int) ->AnyObject {
        if(bookType.selectedSegmentIndex==0){
            
            return self.data[row]
            
        }else{
            
            return self.data2[row]
            
        }
    }
    
    fileprivate func GetBookDataSource() -> [AnyObject] {
        
        if(bookType.selectedSegmentIndex==0){
            
            return self.data
            
        }else{
            
            return self.data2
            
        }

    }

    fileprivate func GetBookType() -> Int{
        
        if(bookType.selectedSegmentIndex==0){
            
            return 1
            
        }else{
            
            return 2
            
        }
    }
    
    fileprivate func setBookData(_ items:[AnyObject],type:Int,isPullRefresh:Bool){
         
         if(isPullRefresh){
            if(type==1) {
                self.data.removeAll(keepingCapacity: false)
            }
            else{
                self.data2.removeAll(keepingCapacity: false)
            }
            
        }
        
        if(type==1) {
            for  it in items {
                
                self.data.append(it);
            }

        }
        else{
            for  it in items {
                
                self.data2.append(it);
            }

        }
        
        
        
        
    }
    
    @IBAction func segmentClick(_ segment: UISegmentedControl) {
        
        let index = segment.selectedSegmentIndex
        
        switch(index){
        case 0:
            if self.data.count == 0 {
                 self.tableView.headerBeginRefreshing()
                loadData(1, maxId: 0, isPullRefresh: true);
            }else {
                self.tableView.reloadData()
            }
            
        case 1:
            if self.data2.count == 0 {
                self.tableView.headerBeginRefreshing()
                loadData(2, maxId: 0, isPullRefresh: true);
            }else{
                self.tableView.reloadData()
            }
            
        default:
            self.tableView.reloadData()
        }
        //self.tableView.reloadData()
        
       print(index)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData(_ type:Int,maxId:Int,isPullRefresh:Bool){
        
        Alamofire.request(Router.bookList(type: type, maxId: maxId, count: 16)).responseJSON{
            closureResponse in
            
            
            if(isPullRefresh){
                self.tableView.headerEndRefreshing()
            }
            else{
                self.tableView.footerEndRefreshing()
            }
            if closureResponse.result.isFailure {
                return
            }
            
            let json = closureResponse.result.value
            
            let result = JSON(json!)
            
            if result["isSuc"].boolValue {
                
                let items = result["result"].object as! [AnyObject]
                
                if(items.count==0){
                    return
                }
                
               
                
                self.setBookData(items,type:type,isPullRefresh:isPullRefresh)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                
                
            }
        }
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
        return self.GetBookDataSource().count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath) as! BookCell
        
        let item: AnyObject = self.getBookData((indexPath as NSIndexPath).row)
        
        // Configure the cell
        var cover = item.value(forKey: "cover") as? String
        if cover != nil {
            if (cover!.hasPrefix("http://img.swiftmi.com")){
                cover = "\(cover!)-book"
            }
            cell.cover.kf.setImage(with: URL(string: cover!)!, placeholder: nil)
        }
        cell.author.text = item.value(forKey: "author") as? String
        
        let pubTime = item.value(forKey: "publishTime") as! Double
        let createDate = Date(timeIntervalSince1970: pubTime)
        cell.year.text = Utility.formatDate(createDate)
        cell.title.text = item.value(forKey: "title") as? String
        
        cell.desc.text = item.value(forKey: "intro") as? String
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item: AnyObject = self.getBookData((indexPath as NSIndexPath).row)
        
        let bookUrl = item.value(forKey: "link") as? String
        if bookUrl != nil {
            
            let webViewController:WebViewController = Utility.GetViewController("webViewController")
            webViewController.webUrl = bookUrl
            webViewController.isPop = true
            
            self.navigationController?.pushViewController(webViewController, animated: true)
            
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
