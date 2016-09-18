//
//  PostDetailController.swift
//  swiftmi
//
//  Created by yangyin on 15/4/4.
//  Copyright (c) 2015年 swiftmi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class PostDetailController: UIViewController,UIScrollViewDelegate,UIWebViewDelegate,UITextViewDelegate {

    @IBOutlet weak var webView: UIWebView! 
    @IBOutlet weak var inputWrapView: UIView!
    
    @IBOutlet weak var inputReply: UITextView!
    var article:AnyObject?
    
    var postId:Int?
    
    var postDetail:JSON = nil
    
    var keyboardShow = false
    
     
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(PostDetailController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(PostDetailController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        //center.addObserver(self, selector:"keyboardWillChangeFrame:", name:UIKeyboardWillChangeFrameNotification,object:nil)
    
      

        
       
        self.setViews()
        
        
        self.inputReply.layer.borderWidth = 1
        self.inputReply.layer.borderColor = UIColor(red: 0.85, green: 0.85, blue:0.85, alpha: 0.9).cgColor
        // Keyboard stuff.

        //
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.userActivity = NSUserActivity(activityType: "com.swiftmi.handoff.view-web")
        self.userActivity?.title = "view article on mac"
        self.userActivity?.webpageURL  =  URL(string: ServiceApi.getTopicShareDetail(self.postId!))
        self.userActivity?.becomeCurrent()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
       NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
        self.userActivity?.invalidate()
    }
    
    func keyboardWillShow(_ notification: Notification) {
        let info:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
       
        
        let duration = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let endKeyboardRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        
        
      
        
        var frame = self.view.frame
        frame.origin.y = -endKeyboardRect.height
         
        
    UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.webView.stringByEvaluatingJavaScript(from: "$('body').css({'padding-top':'\(endKeyboardRect.height)px'});")
            
        for constraint in self.inputWrapView.constraints {
            if constraint.firstAttribute == NSLayoutAttribute.height {
                let inputWrapContraint = constraint as NSLayoutConstraint
                inputWrapContraint.constant = 80
               // self.inputWrapView.updateConstraintsIfNeeded()
                break;
            }
        }
        
            self.view.frame = frame
            
            }, completion: nil)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        let info:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        
        
        
         let duration = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        
        
        var frame = self.view.frame
        frame.origin.y = 0 // keyboardHeight
        
        
        
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.webView.stringByEvaluatingJavaScript(from: "$('body').css({'padding-top':'0px'});")
                self.view.frame = frame
            
            for constraint in self.inputWrapView.constraints {
                if constraint.firstAttribute == NSLayoutAttribute.height {
                    let inputWrapContraint = constraint as NSLayoutConstraint
                    inputWrapContraint.constant = 50
                    // self.inputWrapView.updateConstraintsIfNeeded()
                    break;
                }
            }
            
            }, completion: nil)

    }
    
    
    fileprivate func GetLoadData() -> JSON {
        
        if postDetail != nil {
            return self.postDetail
        }
    
        var json:JSON = ["comments":[]]
        
        json["topic"] =  JSON(self.article!)
     
        return json
    }

    func loadData(){
        
        
        Alamofire.request(Router.topicDetail(topicId: self.postId!)).responseJSON{
            closureResponse in
            
            if closureResponse.result.isFailure {
                
                let alert = UIAlertView(title: "网络异常", message: "请检查网络设置", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
                
            }
            else {
                
                let json = closureResponse.result.value
                
                let result = JSON(json!)
                
                if result["isSuc"].boolValue {
                    
                    self.postDetail =  result["result"]
                    
                }
                
            }
           
            
            let path = Bundle.main.path(forResource:"article", ofType: "html")
            
            let url=NSURL.fileURL(withPath: path!)
            let request = URLRequest(url:url)
            DispatchQueue.main.async {
                self.inputWrapView.isHidden = false
                self.webView.loadRequest(request)

            }

        }
        
    }
    
     func setViews(){
        
        self.view.backgroundColor=UIColor.white
     
        self.webView.backgroundColor=UIColor.clear
        
        self.inputReply.resignFirstResponder()
        self.webView.delegate=self
        self.webView.scrollView.delegate=self
        
        
        if let article = self.article {
            self.postId = article.value(forKey: "postId") as? Int
        }
                
      //  self.inputView
        
        self.startLoading()
        self.inputWrapView.isHidden = true
        self.title="主题贴"
        self.loadData()
        
    
       
    }
    
    @IBAction func replyClick(_ sender: AnyObject) {
        
        let msg = inputReply.text;
        inputReply.text = "";
        if msg != nil {
            
            let postId  = self.postId!
            let params:[String:AnyObject] = ["postId":postId as AnyObject,"content":msg as AnyObject]
            
            
            Alamofire.request(Router.topicComment(parameters: params)).responseJSON{
                closureResponse in
                
                if closureResponse.result.isFailure {
                    
                    self.notice("网络异常", type: NoticeType.error, autoClear: true)
                    return
                }
                
                
                let json = closureResponse.result.value
                let result = JSON(json!)
                
                if result["isSuc"].boolValue {
                    
                    self.notice("评论成功!", type: NoticeType.success, autoClear: true)
                    
                    self.webView.stringByEvaluatingJavaScript(from: "article.addComment("+result["result"].rawString()!+");")
                    
                    
                    
                } else {
                    
                     self.notice("评论失败!", type: NoticeType.error, autoClear: true)
                }
            }
        }
    }
    
    
    func startLoading(){
        self.pleaseWait()
        self.webView.isHidden=true
        
        
    }
    
    func stopLoading(){
        self.webView.isHidden=false
        self.clearAllNotice()
    }


    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool
    {
        let reqUrl=request.url!.absoluteString
        let params = reqUrl.components(separatedBy: "://")
        
        DispatchQueue.main.async(execute: {
            
            
           
            if(params.count>=2){
                if(params[0].compare("html")==ComparisonResult.orderedSame && params[1].compare("docready") ==  ComparisonResult.orderedSame ){
                  
                    
                    let data = self.GetLoadData()
                   
                    self.webView.stringByEvaluatingJavaScript(from: "article.render("+data.rawString()!+");")
                    
                    //add article to index
                    SplotlightHelper.AddItemToCoreSpotlight("article-\(data["topic"]["postId"].intValue)", title: data["topic"]["title"].stringValue, contentDescription: data["topic"]["content"].stringValue)
                    
                    
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


    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func shareClick(_ sender: AnyObject) {
        
        share()
    }
    
    fileprivate func share() {
        
        let data = GetLoadData()
        if let title = data["topic"]["title"].string {
            
        
            // let title = data["topic"]["title"].stringValue
            let url = ServiceApi.getTopicShareDetail(data["topic"]["postId"].intValue)
            let desc = data["topic"]["desc"].stringValue
        
            let img = self.webView.stringByEvaluatingJavaScript(from: "article.getShareImage()")
        
        
            Utility.share(title, desc: desc, imgUrl: img, linkUrl: url)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        self.clearAllNotice()
    }
    

}
