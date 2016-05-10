//
//  CustomWebViewController.swift
//  Eureka
//
//  Created by Paige Sun on 05/10/16.

import UIKit
import WebKit

class CustomWebViewController: UIViewController
{
    var url: NSURL?
    private var webView:UIWebView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        webView = UIWebView(frame: self.view.frame)
        guard url != nil else { return }
        webView.loadRequest(NSURLRequest(URL: url!))
        self.view.addSubview(webView)
    }
}