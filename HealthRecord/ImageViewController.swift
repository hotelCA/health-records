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
    var dot: UIView!
    var panGesture: UIPanGestureRecognizer!
    
    @IBAction func deletePressed(_ sender: Any) {

        delegate.deleteAHealthImage()
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = healthImage?.image

        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        panGesture.minimumNumberOfTouches = 0

        dot = UIView(frame: CGRect(origin: CGPoint(x: -15, y: -15), size: CGSize(width: 30, height: 30)))
        dot.backgroundColor = .red
        dot.clipsToBounds = true
        dot.layer.cornerRadius = 15
        self.view.addSubview(dot)

        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(panGesture)
    }

    @objc func draggedView(_ sender: UIPanGestureRecognizer) {

        self.view.bringSubview(toFront: dot)
        let translation = sender.translation(in: self.view)
        dot.center = CGPoint(x: dot.center.x + translation.x, y: dot.center.y + translation.y)

        sender.setTranslation(CGPoint.zero, in: self.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch in touches {

            let location = touch.location(in: self.view)
            dot.center.x = location.x
            dot.center.y = location.y
        }
    }
}

