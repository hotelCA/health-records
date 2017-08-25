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

    @IBAction func testButtonPressed(_ sender: Any) {

        if stateController.mode == .normal {

            stateController.mode = .printing

        } else {

            stateController.mode = .normal
        }

        tableView.reloadData()
    }

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

            self.takeAPhoto()
        }

        let uploadFileAction = UIAlertAction(title: "Upload a file", style: .default) { _ in

            self.loadAnImage()
        }

        let addConditionAction = UIAlertAction(title: "Add a condition", style: .default) { _ in

            self.addADescription()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }

        actionSheet.addAction(takePhotoAction)
        actionSheet.addAction(uploadFileAction)
        actionSheet.addAction(addConditionAction)
        actionSheet.addAction(cancelAction)
    }

    private func takeAPhoto() {

        imageHandler.pickAPhotoFromCamera()
    }

    private func loadAnImage() {

        imageHandler.pickAPhotoFromGallery()
    }

    private func addADescription() {

        let descriptionHandler = DescriptionHandler(viewController: self)
        descriptionHandler.addNewCondition()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "toImageView" {

            if let destination = segue.destination as? ImageViewController {

                destination.healthImage = sender as! HealthImage?
            }

        } else if segue.identifier == "toWebView" {

            if let destination = segue.destination as? WebViewController {

                let htmlController = HtmlController()
                let pdfController = PdfController()

                destination.url = URL(string: htmlController.pathToHTMLTemplate!)

                let printRows = tableViewDataSource.getDataForPrinting()

                if printRows.count > 0 {

                    destination.webContent = htmlController.renderHealthRecord(printRows, stateController.healthRecords)
                    
                    pdfController.exportHTMLContentToPDF(htmlContent: destination.webContent)
                }
            }
        }
    }
}
    
