//
//  SwiftCodeController.swift
//  swiftmi
//
//  Created by yangyin on 15/4/1.
//  Copyright (c) 2015年 swiftmi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


let reuseIdentifier = "CodeCell"

class SwiftCodeController: UICollectionViewController,UICollectionViewDelegateFlowLayout {
 
    let sectionInsets = UIEdgeInsets(top:6, left: 6, bottom: 6, right: 6)
    
    internal var data:[AnyObject] = [AnyObject]()
    
    var loading:Bool = false
 
    
    fileprivate func getDefaultData(){
        
        let dalCode = CodeDal()
        
        let result = dalCode.getCodeList()
        
        if result != nil {
            
            self.data = result!
            self.collectionView?.reloadData()
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.collectionViewLayout.collectionView?.backgroundColor = UIColor.white
        
        self.collectionView?.addHeaderWithCallback{
            self.loadData(0, isPullRefresh: true)
        }
      
                
       // (self.collectionViewLayout as! UICollectionViewFlowLayout).estimatedItemSize =   CGSize(width: width, height: 380)
        
        self.collectionView?.addFooterWithCallback{
            
            if(self.data.count>0) {
                let  maxId = self.data.last!.value(forKey: "codeId") as! Int
                self.loadData(maxId, isPullRefresh: false)
            }
        }
        
        getDefaultData()
        
        self.collectionView?.headerBeginRefreshing()

    }
    
    



    func loadData(_ maxId:Int,isPullRefresh:Bool){
        if self.loading {
            return
        }
        self.loading = true
        
        
        Alamofire.request(Router.codeList(maxId: maxId, count: 12)).responseJSON{
            closureResponse in
            
            self.loading = false
            
            if(isPullRefresh){
                
                 self.collectionView?.headerEndRefreshing()
            }
            else{
                self.collectionView?.footerEndRefreshing()
            }
            if closureResponse.result.isFailure {
                self.notice("网络异常", type: NoticeType.error, autoClear: true)
                return
            }
            
            
            let json = closureResponse.result.value;
            
            let result = JSON(json!)
            
            if result["isSuc"].boolValue {
                
                let items = result["result"]
                
                if(items.count==0){
                    return
                }
                
                if(isPullRefresh){
                    
                    
                    let dalCode = CodeDal()
                    dalCode.deleteAll()
                    
                    dalCode.addList(items)
                    
                    self.data.removeAll(keepingCapacity: false)
                }
                
                 
                for  it in items {
                    
                    self.data.append(it.1.object as AnyObject);
                    
                   // println("data length \(self.data.count)")
                }
                
                DispatchQueue.main.async{
                    
                    self.collectionView!.reloadData()
                    
                }
                
                
                
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        var item = self.collectionView?.indexPathsForSelectedItems
        
        if item?.count > 0 {
            
            let indexPath = item![0] 
            
            if segue.destination is CodeDetailViewController {
                let view = segue.destination as! CodeDetailViewController
                
                let code: AnyObject = self.data[(indexPath as NSIndexPath).row]
                view.shareCode = code
                
                
            }
        }
        
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return self.data.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView!.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CodeCell
     
    
        let item: AnyObject = self.data[(indexPath as NSIndexPath).row]
        
        // Configure the cell
        var preview = item.value(forKey: "preview") as? String
        if preview != nil {
            if (preview!.hasPrefix("http://img.swiftmi.com")){
                preview = "\(preview!)-code"
            }
            cell.preview.kf.setImage(with: URL(string: preview!)!, placeholder: nil)
        }
        
        let pubTime = item.value(forKey: "createTime") as! Double
        let createDate = Date(timeIntervalSince1970: pubTime)
        
        cell.timeLabel.text = Utility.formatDate(createDate)
        
        cell.title.text = item.value(forKey: "title") as? String
       
       
       //cell.addShadow()
        
        

        
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let frame  = self.view.frame;
        var width = frame.width

        
        if (frame.width > frame.height) {
            width = frame.height
        }
        width = CGFloat(Int((width-18)/2))
       // println("width....\(width)")
        return CGSize(width: width, height: 380)
        
    }
    

    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 6
    }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
     {
         return 6
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return sectionInsets
    }
 
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        collectionView.layer.shadowOpacity = 0.8 
        return true
    }
    
    
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    

}
