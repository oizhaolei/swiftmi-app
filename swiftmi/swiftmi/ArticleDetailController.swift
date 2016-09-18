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
    
    fileprivate func setViews(){
        
        self.view.backgroundColor=UIColor.white
        self.webView.backgroundColor=UIColor.clear
        self.webView.delegate = self
        self.startLoading()
        
        
        if let art = self.article {
            self.articleId = art.value(forKey: "articleId") as? Int
        }
        
        self.loadData()
        
    }
    
    fileprivate func GetLoadData() -> JSON {
        
        if self.newArticle != nil {
            return self.newArticle!
        }
        //use old data
        return JSON(self.article!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.userActivity = NSUserActivity(activityType: "com.swiftmi.handoff.view-web")
        self.userActivity?.title = "view article on mac"
        self.userActivity?.webpageURL  =  URL(string: ServiceApi.getArticlesDetail(self.articleId!))
        self.userActivity?.becomeCurrent()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.userActivity?.invalidate()
        self.clearAllNotice()

    }
    
    fileprivate func loadData(){
        
        Alamofire.request(Router.articleDetail(articleId: self.articleId!)).responseJSON{
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
            
            
            let path=Bundle.main.path(forResource: "next", ofType: "html")
            
            let url=NSURL.fileURL(withPath: path!)
            let request = NSURLRequest(url:url)
            DispatchQueue.main.async {
                self.webView.loadRequest(request as URLRequest)
            }
            
        }
        
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool
    {
        
        let reqUrl=request.url!.absoluteString
        var params = reqUrl.components(separatedBy: "://")
        
        DispatchQueue.main.async(execute: {
            
            
            
            if(params.count>=2){
                if(params[0].compare("html")==ComparisonResult.orderedSame && params[1].compare("docready") ==  ComparisonResult.orderedSame ){
                    
                    
                    let data = self.GetLoadData()
                    
                    self.webView.stringByEvaluatingJavaScript(from: "article.render("+data.rawString()!+");")
                    
                    //add article to index
                    SplotlightHelper.AddItemToCoreSpotlight("next-\(data["articleId"].intValue)", title: data["title"].stringValue, contentDescription: data["content"].stringValue)
                    
                    
                }
                else if(params[0].compare("html")==ComparisonResult.orderedSame && params[1].compare("contentready")==ComparisonResult.orderedSame){
                    
                    //doc content ok
                    self.stopLoading()
                }
                else if params[0].compare("http") == ComparisonResult.orderedSame || params[0].compare("https") == ComparisonResult.orderedSame  {
                    
                    let webViewController:WebViewController = Utility.GetViewController("webViewController")
                    webViewController.webUrl = reqUrl
                    self.present(webViewController, animated: true, completion: nil)
                    
                }
                
            }
            
            
            
        })
        if params[0].compare("http") == ComparisonResult.orderedSame || params[0].compare("https") == ComparisonResult.orderedSame {
            return false
        }
        return true;
    }
    
    fileprivate func startLoading(){
        self.pleaseWait()
        self.webView.isHidden=true
        
        
    }
    
    fileprivate func stopLoading(){
        self.webView.isHidden=false
        self.clearAllNotice()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func share() {
        
        var data = GetLoadData()
        let title = data["title"].stringValue
        let url = ServiceApi.getArticlesShareDetail(self.articleId!)
        let desc = data["desc"].stringValue
        let preview = data["imageUrl"].stringValue
        Utility.share(title, desc: desc, imgUrl: preview, linkUrl: url)
        
    }
    
    @IBAction func shareArticle(_ sender: AnyObject) {
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
