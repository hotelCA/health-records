//
//  ViewController.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/15/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

protocol ImageViewControllerProtocol {

    func deleteAHealthImage()
}

class ImageViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    var healthImage: HealthImage?
    var delegate: ImageViewControllerProtocol!
    
    @IBAction func deletePressed(_ sender: Any) {

        delegate.deleteAHealthImage()
        _ = navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = healthImage?.image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

