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
    var imageHandler: ImageHandler!
    var conditionHandler: ConditionHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        tableViewDataSource = TableViewDataSource(healthRecords: stateController.healthRecords)

        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDataSource
        tableView.reloadData()

        imageHandler = ImageHandler(viewController: self)
        conditionHandler = ConditionHandler(viewController: self)
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

            self.imageHandler.pickAPhoto()
        }

        let addConditionAction = UIAlertAction(title: "Add a condition", style: .default) { _ in

            self.conditionHandler.addNewCondition()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in

            print("Cancel action trigerred.")
        }

        actionSheet.addAction(takePhotoAction)
        actionSheet.addAction(uploadFileAction)
        actionSheet.addAction(addConditionAction)
        actionSheet.addAction(cancelAction)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "toImageView" {

            if let destination = segue.destination as? ViewController {

                destination.healthImage = sender as! HealthImage?
            }

        } else if segue.identifier == "toConditionPicker" {

            if let destination = segue.destination as? AddConditionViewController {

            }
        }
    }
}
    
