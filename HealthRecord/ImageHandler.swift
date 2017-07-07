//
//  ImagePickerController.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/30/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

class ImageHandler: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var viewController: TableViewController!

    init(viewController: TableViewController) {

        self.viewController = viewController
    }

    func pickAPhoto() {

        let imagePickerController = UIImagePickerController()

        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        imagePickerController.delegate = self

        viewController.present(imagePickerController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {

            let healthImage: HealthImage = HealthImage(timeOfImage: Date(), image: image)

            viewController.performSegue(withIdentifier: "toImageView", sender: healthImage)
        }

        viewController.dismiss(animated: true, completion: nil)
    }

}
