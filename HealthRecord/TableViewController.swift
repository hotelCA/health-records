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
    var htmlController: HtmlController!
    var pdfController: PdfController!
    var imageHandler: ImageHandler!
    var conditionHandler: ConditionHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        tableViewDataSource = TableViewDataSource(stateController: stateController)

        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDataSource
        tableViewDataSource.tableView = tableView
        tableView.reloadData()

        imageHandler = ImageHandler(viewController: self)
        conditionHandler = ConditionHandler(viewController: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Nothing yet
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func unwindToTableViewController(unwindSegue: UIStoryboardSegue) {

        if let source = unwindSegue.source as? AddConditionViewController {

            let healthDescription = source.getNewCondition()

            updateStateAndDataSource(healthCondition: healthDescription)
        }
    }

    func updateStateAndDataSource(healthCondition: HealthCondition) {

        stateController.saveARecord(healthCondition: healthCondition)
        tableViewDataSource.showNewCondition(newCondition: healthCondition)
    }

    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {

        createAndPresentActionSheet()
    }

    func createAndPresentActionSheet() {

        let actionSheet = UIAlertController(title: nil, message: "Pick an action", preferredStyle: .actionSheet)

        createAndAddActionsToActionSheet(actionSheet: actionSheet)
        
        present(actionSheet, animated: true, completion: nil)
    }

    func createAndAddActionsToActionSheet(actionSheet: UIAlertController) {

        let takePhotoAction = UIAlertAction(title: "Camera", style: .default) { _ in

            self.imageHandler.pickAPhotoFromCamera()
        }

        let uploadFileAction = UIAlertAction(title: "Upload a file", style: .default) { _ in

            self.imageHandler.pickAPhotoFromGallery()
        }

        let addConditionAction = UIAlertAction(title: "Add a condition", style: .default) { _ in

            self.conditionHandler.addNewCondition()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }

        actionSheet.addAction(takePhotoAction)
        actionSheet.addAction(uploadFileAction)
        actionSheet.addAction(addConditionAction)
        actionSheet.addAction(cancelAction)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "toImageView" {

            if let destination = segue.destination as? ImageViewController {

                destination.healthImage = sender as! HealthImage?
            }

        } else if segue.identifier == "toWebView" {

            if let destination = segue.destination as? WebViewController {

                destination.url = URL(string: htmlController.pathToHTMLTemplate!)
                destination.webContent = htmlController.renderHealthRecord(healthRecords: stateController.healthRecords)
                pdfController.exportHTMLContentToPDF(htmlContent: destination.webContent)
            }
        }
    }
}
    
