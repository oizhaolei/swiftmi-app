//
//  WebViewController.swift
//  swiftmi
//
//  Created by yangyin on 15/5/3.
//  Copyright (c) 2015年 swiftmi. All rights reserved.
//

import UIKit

class WebViewController: UIViewController,UIWebViewDelegate {

    internal var isPop:Bool = false
    
    internal var webUrl:String?
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView.delegate = self
        if webUrl != nil {
            
            self.pleaseWait()
            
            let url = URL(string: webUrl!)
            let request = URLRequest(url: url!)
            webView.loadRequest(request)
        }
        if self.title == nil {
            self.title = "内容"

        }
        
        setWebViewTop()
        // Do any additional setup after loading the view.
    }

   
    fileprivate func setWebViewTop(){
        
        if self.isPop {
            for constraint in self.view.constraints {
                if constraint.firstAttribute == NSLayoutAttribute.top {
                    let inputWrapContraint = constraint as NSLayoutConstraint
                    inputWrapContraint.constant =  UIApplication.shared.statusBarFrame.height+self.navigationController!.navigationBar.frame.height
                     
                    break;
                }
            }
            
            
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        setWebViewTop()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func stopAndClose(_ sender: AnyObject) {
        
        webView.stopLoading()

         self.clearAllNotice()
        if self.isPop {
            self.navigationController?.popViewController(animated: true)
            
        }else {
            self.dismiss(animated: true, completion: nil)
        }
       
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.clearAllNotice()
    }
    
    @IBAction func refreshWebView(_ sender: AnyObject) {
         webView.reload()
        
    }
    
    
    @IBAction func rewindWebView(_ sender: AnyObject) {
        
 
         webView.goBack()
    }

    @IBAction func forwardWebView(_ sender: AnyObject) {
        
         webView.goForward()
    }
    
    
    @IBAction func shareClick(_ sender: AnyObject) {
        
        let url = URL(fileURLWithPath:self.webView.request!.url!.absoluteString)
        let title = self.webView.stringByEvaluatingJavaScript(from: "document.title")
        
        let activityViewController = UIActivityViewController(activityItems: [title!,url], applicationActivities: nil)
        self.present(activityViewController, animated: true,completion:nil)
       
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool
    {
       self.clearAllNotice()
        self.pleaseWait()
        return true 
    }
    func webViewDidStartLoad(_ webView: UIWebView)
    {
        
    }
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        self.clearAllNotice()
        
        self.title =  self.webView.stringByEvaluatingJavaScript(from: "document.title")
        
        
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
    
    
        self.clearAllNotice()
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        self.clearAllNotice()
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
