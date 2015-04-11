//
//  DADocViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/18/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DADocViewController: DAViewController, UIWebViewDelegate {
    
    var documentView = DADocumentView()
    var documentURL: NSURL?
    var documentTitle: String?
    var documentPath: String?
    
    init(url: NSURL, title: String) {
        super.init(nibName: nil, bundle: nil)
        documentURL = url
        documentTitle = title
    }
    
    init(filePath: String, title: String) {
        super.init(nibName: nil, bundle: nil)
        documentPath = filePath
        documentTitle = title
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        documentView.webView.delegate = self
        reloadDocument()
    }
    
    private func loadURL() {
        animateSpinner()
        dispatch_async(dispatch_get_main_queue(), {
            let urlRequest = NSURLRequest(URL: self.documentURL!)
            self.documentView.webView.loadRequest(urlRequest)
        })
    }
    
    private func loadDocument() {
        animateSpinner()
        dispatch_async(dispatch_get_main_queue(), {
            let fileContents = String(contentsOfFile: self.documentPath!, encoding: NSUTF8StringEncoding, error: nil)
            self.documentView.webView.loadHTMLString(fileContents, baseURL: nil)
        })
    }
    
    private func animateSpinner() {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        let spinnerItem = UIBarButtonItem(customView: spinner)
        navigationItem.rightBarButtonItem = spinnerItem
        spinner.startAnimating()
    }
    
    func reloadDocument() {
        if documentURL != nil {
            loadURL()
        }
        else if documentPath != nil {
            loadDocument()
        }
        
        navigationItem.title = documentTitle
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        navigationItem.rightBarButtonItem = nil
    }
    
    override func loadView() {
        view = documentView
    }
}