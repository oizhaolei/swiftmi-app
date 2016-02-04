//
//  ArticleDetailController.swift
//  swiftmi
//
//  Created by yangyin on 16/2/3.
//  Copyright © 2016年 swiftmi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class ArticleDetailController: UIViewController,UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    var article:AnyObject?
    
    var newArticle:JSON?
    
    var articleId:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setViews()
        // Do any additional setup after loading the view.
    }
    
    private func setViews(){
        
        self.view.backgroundColor=UIColor.whiteColor()
        self.webView.backgroundColor=UIColor.clearColor()
        self.webView.delegate = self
        self.startLoading()
        
        
        if let art = self.article {
            self.articleId = art.valueForKey("articleId") as? Int
        }
        
        self.loadData()
        
    }
    
    private func GetLoadData() -> JSON {
        
        if self.newArticle != nil {
            return self.newArticle!
        }
        //use old data
        return JSON(self.article!)
    }
    
    private func loadData(){
        
        Alamofire.request(Router.ArticleDetail(articleId: self.articleId!)).responseJSON{
            closureResponse in
            
            if(closureResponse.result.isFailure){
                
                self.notice("网络异常", type: NoticeType.error, autoClear: true)
            }
            else {
                let json = closureResponse.result.value
                
                let result = JSON(json!)
                
                if result["isSuc"].boolValue {
                    self.newArticle =  result["result"]
                }
                
            }
            
            
            let path=NSBundle.mainBundle().pathForResource("next", ofType: "html")
            
            let url=NSURL.fileURLWithPath(path!)
            let request = NSURLRequest(URL:url)
            dispatch_async(dispatch_get_main_queue()) {
                
                self.webView.loadRequest(request)
            }
            
        }
        
    }

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool
    {
        
        let reqUrl=request.URL!.absoluteString
        var params = reqUrl.componentsSeparatedByString("://")
        
        dispatch_async(dispatch_get_main_queue(),{
            
            
            
            if(params.count>=2){
                if(params[0].compare("html")==NSComparisonResult.OrderedSame && params[1].compare("docready") ==  NSComparisonResult.OrderedSame ){
                    
                    
                    let data = self.GetLoadData()
                    
                    self.webView.stringByEvaluatingJavaScriptFromString("article.render("+data.rawString()!+");")
                    
                    //add article to index
                    SplotlightHelper.AddItemToCoreSpotlight("next-\(data["articleId"].intValue)", title: data["title"].stringValue, contentDescription: data["content"].stringValue)
                    
                    
                }
                else if(params[0].compare("html")==NSComparisonResult.OrderedSame && params[1].compare("contentready")==NSComparisonResult.OrderedSame){
                    
                    //doc content ok
                    self.stopLoading()
                }
                else if params[0].compare("http") == NSComparisonResult.OrderedSame || params[0].compare("https") == NSComparisonResult.OrderedSame  {
                    
                    let webViewController:WebViewController = Utility.GetViewController("webViewController")
                    webViewController.webUrl = reqUrl
                    self.presentViewController(webViewController, animated: true, completion: nil)
                    
                }
                
            }
            
            
            
        })
        if params[0].compare("http") == NSComparisonResult.OrderedSame || params[0].compare("https") == NSComparisonResult.OrderedSame {
            return false
        }
        return true;
    }
    
    private func startLoading(){
        self.pleaseWait()
        self.webView.hidden=true
        
        
    }
    
    private func stopLoading(){
        self.webView.hidden=false
        self.clearAllNotice()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func share() {
        
        var data = GetLoadData()
        
        
        let title = data["title"].stringValue
        let url = ServiceApi.getArticlesDetail(self.articleId!)
        let desc = data["desc"].stringValue
        
        let preview = data["imageUrl"].stringValue
        
        
        Utility.share(title, desc: desc, imgUrl: preview, linkUrl: url)
        
    }
    
    @IBAction func shareArticle(sender: AnyObject) {
        share()
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
