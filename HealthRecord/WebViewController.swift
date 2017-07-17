//
//  WebViewController.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 7/14/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet var webView: UIWebView!
    var webContent: String!
    var url: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if webContent != nil && url != nil{

            webView.loadHTMLString(webContent, baseURL: url)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
