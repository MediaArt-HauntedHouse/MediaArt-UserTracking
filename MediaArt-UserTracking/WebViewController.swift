//
//  WebViewController.swift
//  MediaArt-UserTracking
//
//  Created by Masaki Kobayashi on 2014/11/02.
//  Copyright (c) 2014年 Masaki Kobayashi. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webv: UIWebView!
    
    var webview: UIWebView = UIWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.webview.frame = self.view.bounds
        self.webview.delegate = self;
        self.view.addSubview(self.webview)
        
        var url: NSURL = NSURL(string: "http://mediaart-hauntedhouse.makky.io/paint")!
        var urlRequest: NSURLRequest = NSURLRequest(URL: url)
        self.webview.loadRequest(urlRequest)
    }
    
    func webView(webView: UIWebView!, shouldStartLoadWithRequest request: NSURLRequest!, navigationType: UIWebViewNavigationType) -> Bool {
        
        return true
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
