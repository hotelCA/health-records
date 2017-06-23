//
//  ViewController.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/15/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var ImageView: UIImageView!
    var HealthImage: HealthImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.ImageView.image = self.HealthImage?.image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

