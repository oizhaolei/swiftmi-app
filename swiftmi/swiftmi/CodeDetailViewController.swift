//
//  CodeDetailViewController.swift
//  swiftmi
//
//  Created by yangyin on 15/4/28.
//  Copyright (c) 2015年 swiftmi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher


class CodeDetailViewController: UIViewController,UIWebViewDelegate {


    var shareCode:AnyObject?
    
    var newShareCode:JSON?
    
    var codeId:Int?
    
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setViews()
        
        
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        
        
        self.userActivity = NSUserActivity(activityType: "com.swiftmi.handoff.view-web")
        self.userActivity?.title = "view source on mac"
        self.userActivity?.webpageURL  =  URL(string: ServiceApi.getCodeShareDetail(self.codeId!))
        self.userActivity?.becomeCurrent()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setViews(){
        
        self.view.backgroundColor=UIColor.white
        self.webView.backgroundColor=UIColor.clear
        self.webView.delegate = self
        self.startLoading()
        
        
        if let shareCode = self.shareCode {
            self.codeId = shareCode.value(forKey: "codeId") as? Int
        }
        
        self.loadData()
         
    }
    
    fileprivate func startLoading(){
        self.pleaseWait()
        self.webView.isHidden=true
        
        
    }
    
   fileprivate func stopLoading(){
        self.webView.isHidden=false
        self.clearAllNotice()
    }
    
    
    fileprivate func GetLoadData() -> JSON {
        
        if newShareCode != nil {
            return self.newShareCode!
        }
        
        var json:JSON = ["comments":[]]
        json["code"] =  JSON(self.shareCode!)
        
        return json
    }
    

   fileprivate func loadData(){
        
        Alamofire.request(Router.codeDetail(codeId: self.codeId!)).responseJSON{
            closureResponse in
            
            if(closureResponse.result.isFailure){
                
                self.notice("网络异常", type: NoticeType.error, autoClear: true)
            }
            else {
                let json = closureResponse.result.value
                
                let result = JSON(json!)
                
                if result["isSuc"].boolValue {
                    
                    self.newShareCode =  result["result"]
                    
                }
                
            }
            
            
            let path = Bundle.main.path(forResource: "code", ofType: "html")
            
            let url = NSURL.fileURL(withPath: path!)
            let request = URLRequest(url:url)
            
            DispatchQueue.main.async {
                
                self.webView.loadRequest(request)
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
                    SplotlightHelper.AddItemToCoreSpotlight("code-\(data["code"]["codeId"].intValue)", title: data["code"]["title"].stringValue, contentDescription: data["code"]["content"].stringValue)
                    
                    
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
    func webViewDidStartLoad(_ webView: UIWebView)
    {
        
    }
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        
    }
    
    
    @IBAction func shareClick(_ sender: AnyObject) {
        
        share()
    }
    
    fileprivate func share() {
        
        var data = GetLoadData()
        
        
        let title = data["code"]["title"].stringValue
        let url = ServiceApi.getCodeShareDetail(self.codeId!)
        let desc = data["code"]["desc"].stringValue
        
        var preview = data["code"]["preview"].stringValue
        
        if preview != "" {
            
            if (preview.hasPrefix("http://img.swiftmi.com")){
                preview = "\(preview)-code"
            }
        }
        
        
        Utility.share(title, desc: desc, imgUrl: preview, linkUrl: url)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        self.clearAllNotice()
        
        self.userActivity?.invalidate()
        
        
        super.viewDidDisappear(animated)
        
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
