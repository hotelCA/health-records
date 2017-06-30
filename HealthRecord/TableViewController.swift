//
//  TableViewController.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/15/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

let ONE_DAY = 3600 * 24
let OneMonth = ONE_DAY * 30
let OneYear = OneMonth * 12


class TableViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var tableView: UITableView!
    var tableViewDataSource: TableViewDataSource!
    var stateController: StateController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        tableViewDataSource = TableViewDataSource(healthRecords: stateController.healthRecords)

        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDataSource

        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {

        createAndPresentActionSheet()
    }

    @IBAction func unwindToTableViewController(unwindSegue: UIStoryboardSegue) {

        if let source = unwindSegue.source as? AddConditionViewController {

//            let healthCondition: HealthCondition = source.getCondition()
//            print("unwind condition: \(healthCondition.condition)")
//            print("unwind degree: \(healthCondition.degree)")
//            print("unwind location: \(healthCondition.location)")
//            print("unwind description: \(healthCondition.description)")
        }
    }


    func createAndPresentActionSheet() {

        let actionSheet = UIAlertController(title: nil, message: "Pick an action", preferredStyle: .actionSheet)

        createAndAddActionsToActionSheet(actionSheet: actionSheet)
        
        self.present(actionSheet, animated: true, completion: nil)
    }

    func createAndAddActionsToActionSheet (actionSheet: UIAlertController) {

        let takePhotoAction = UIAlertAction(title: "Take a photo", style: .default) { _ in

            print("Take a photo action triggered.")
        }

        let uploadFileAction = UIAlertAction(title: "Upload a file", style: .default) { _ in

            self.pickAPhoto()
        }

        let addConditionAction = UIAlertAction(title: "Add a condition", style: .default) { _ in

            self.addNewCondition()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in

            print("Cancel action trigerred.")
        }

        actionSheet.addAction(takePhotoAction)
        actionSheet.addAction(uploadFileAction)
        actionSheet.addAction(addConditionAction)
        actionSheet.addAction(cancelAction)
    }

    func pickAPhoto() {

        let imagePickerController = UIImagePickerController()

        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        imagePickerController.delegate = self

        self.present(imagePickerController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {

            let healthImage: HealthImage = HealthImage(image: image)

            performSegue(withIdentifier: "imageViewSegue", sender: healthImage)
        }

        self.dismiss(animated: true, completion: nil)
    }

    func addNewCondition() {

        performSegue(withIdentifier: "toConditionPicker", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "imageViewSegue" {

            if let destination = segue.destination as? ViewController {

                destination.HealthImage = sender as! HealthImage?
            }

        } else if segue.identifier == "toConditionPicker" {

            if let destination = segue.destination as? AddConditionViewController {

            }
        }

        var newFloat: Float
    }
}
    
