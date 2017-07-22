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

    func pickAPhotoFromGallery() {

        let imagePickerController = UIImagePickerController()

        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        imagePickerController.delegate = self

        viewController.present(imagePickerController, animated: true, completion: nil)
    }

    func pickAPhotoFromCamera() {

        let imagePickerController = UIImagePickerController()

        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = false
        imagePickerController.delegate = self

        viewController.present(imagePickerController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {

            UIGraphicsBeginImageContext(CGSize(width: 200, height: 200))
            image.draw(in: CGRect(x: 0, y: 0, width: 200, height: 200))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            let healthImage: HealthImage = HealthImage(timeOfImage: Date(), image: resizedImage!)

            viewController.updateStateAndDataSource(healthCondition: healthImage)
//            viewController.performSegue(withIdentifier: "toImageView", sender: healthImage)
        }

        viewController.dismiss(animated: true, completion: nil)
    }

}
