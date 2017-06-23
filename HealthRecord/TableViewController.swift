//
//  TableViewController.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/15/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var Expand: Bool = false

    func loadCellDescriptors() {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            let cellDescriptors = NSDictionary(contentsOfFile: path)
            print(cellDescriptors)
        }
    }

    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {

        createAndPresentActionSheet()
    }

    @IBAction func unwindToTableViewController(unwindSegue: UIStoryboardSegue) {

        if let source = unwindSegue.source as? AddConditionViewController {

            let healthCondition: HealthCondition = source.getCondition()
            print("unwind condition: \(healthCondition.condition)")
            print("unwind degree: \(healthCondition.degree)")
            print("unwind location: \(healthCondition.location)")
            print("unwind description: \(healthCondition.description)")
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

            self.PickAPhoto()

        }

        let addConditionAction = UIAlertAction(title: "Add a condition", style: .default) { _ in

            self.AddNewCondition()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in

            print("Cancel action trigerred.")
        }

        actionSheet.addAction(takePhotoAction)
        actionSheet.addAction(uploadFileAction)
        actionSheet.addAction(addConditionAction)
        actionSheet.addAction(cancelAction)
    }

    func PickAPhoto() {

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

    func AddNewCondition() {

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
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        loadCellDescriptors()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 10
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if Expand == false {

            if indexPath.row % 2 == 0 {

                return 65.0

            } else {

                return 150.0
            }

        } else {

            if indexPath.row < 4 {

                return 65.0

            } else {

                if indexPath.row % 2 == 0 {

                    return 65.0

                } else {

                    return 150.0
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if Expand == false {

            if indexPath.row % 2 == 0 {

                let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as! DescriptionTableViewCell

                descriptionCell.MedicalDescriptionLabel?.text = "Test"
                return descriptionCell

            } else {

                let imageCell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageTableViewCell

                imageCell.MedicalImage?.image = UIImage(named: "20160704_145508.jpg")
                return imageCell
            }

        } else {

            if indexPath.row < 4 {
                
                let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as! DescriptionTableViewCell

                descriptionCell.MedicalDescriptionLabel?.text = "Test"
                return descriptionCell

            } else {

                if indexPath.row % 2 == 0 {

                    let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as! DescriptionTableViewCell

                    descriptionCell.MedicalDescriptionLabel?.text = "Test"
                    return descriptionCell

                } else {

                    let imageCell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageTableViewCell

                    imageCell.MedicalImage?.image = UIImage(named: "20160704_145508.jpg")
                    return imageCell
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let descriptionCell = tableView.cellForRow(at: indexPath) as? DescriptionTableViewCell {

            if descriptionCell.ExpandLabel?.text == "+" {

                descriptionCell.ExpandLabel.text = "-"
                Expand = true
                tableView.reloadSections([0], with: .bottom)
            }
        }
    }
    
}
