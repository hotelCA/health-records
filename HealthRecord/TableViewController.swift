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

class TableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var Expand: Bool = false

    var healthRecords = [
    HealthCondition(timeOfCondition: Date(timeIntervalSinceNow: TimeInterval(4*OneMonth))),
    HealthCondition(timeOfCondition: Date(timeIntervalSinceNow: TimeInterval(8*OneMonth))),
    HealthCondition(timeOfCondition: Date(timeIntervalSinceNow: TimeInterval(12*OneMonth))),
    HealthCondition(timeOfCondition: Date(timeIntervalSinceNow: TimeInterval(16*OneMonth))),
    HealthCondition(timeOfCondition: Date(timeIntervalSinceNow: TimeInterval(20*OneMonth))),
    HealthCondition(timeOfCondition: Date(timeIntervalSinceNow: TimeInterval(24*OneMonth))),
    HealthCondition(timeOfCondition: Date(timeIntervalSinceNow: TimeInterval(28*OneMonth))),
    HealthCondition(timeOfCondition: Date(timeIntervalSinceNow: TimeInterval(32*OneMonth))),
    HealthCondition(timeOfCondition: Date(timeIntervalSinceNow: TimeInterval(36*OneMonth)))]

    var shownCells = [Any]()
    

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

        var newFloat: Float
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        for i in 0..<healthRecords.count {

            print(healthRecords[i].date)
        }

        initShownCells()
        printShownCells()
    }

    func initShownCells() {

        let calendarComponentFlags: Set<Calendar.Component> = [.year]
        var prevDateComponents: DateComponents = Calendar.current.dateComponents(calendarComponentFlags, from: Date(timeIntervalSince1970: 0))

        for healthRecord in healthRecords {

            var dateComponents = Calendar.current.dateComponents(calendarComponentFlags, from: healthRecord.date!)

            if isANewDate(prevDate: prevDateComponents, currentDate: dateComponents, inTermsOf: DateComponent.year) {

                shownCells.append(YearHeaderCell(year: dateComponents.year!))
            }

//            if isANewDate(prevDate: prevDateComponents, currentDate: dateComponents, inTermsOf: DateComponent.day) {
//
//                shownCells.append(DayHeaderCell(day: dateComponents.day!))
//            }

            prevDateComponents = dateComponents
        }
    }

    // TODO: Write test case for this
    func isANewDate(prevDate: DateComponents, currentDate: DateComponents, inTermsOf: DateComponent) -> Bool {

        switch inTermsOf {

        case .year:

            if prevDate.year != currentDate.year {

                return true
            }

        case .month:

            if prevDate.year != currentDate.year ||
               prevDate.month != currentDate.month {

                return true
            }

        case .day:

            if prevDate.year != currentDate.year ||
               prevDate.month != currentDate.month ||
               prevDate.day != currentDate.day {

                return true
            }

        }

        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return shownCells.count
    }

//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//        if Expand == false {
//
//            if indexPath.row % 2 == 0 {
//
//                return 65.0
//
//            } else {
//
//                return 150.0
//            }
//
//        } else {
//
//            if indexPath.row < 4 {
//
//                return 65.0
//
//            } else {
//
//                if indexPath.row % 2 == 0 {
//
//                    return 65.0
//
//                } else {
//
//                    return 150.0
//                }
//            }
//        }
//    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

//        if Expand == false {
//
//            if indexPath.row % 2 == 0 {
//
//                let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as! DescriptionTableViewCell
//
//                descriptionCell.MedicalDescriptionLabel?.text = "Test"
//                return descriptionCell
//
//            } else {
//
//                let imageCell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageTableViewCell
//
//                imageCell.MedicalImage?.image = UIImage(named: "20160704_145508.jpg")
//                return imageCell
//            }
//
//        } else {
//
//            if indexPath.row < 4 {
//                
//                let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as! DescriptionTableViewCell
//
//                descriptionCell.MedicalDescriptionLabel?.text = "Test"
//                return descriptionCell
//
//            } else {
//
//                if indexPath.row % 2 == 0 {
//
//                    let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as! DescriptionTableViewCell
//
//                    descriptionCell.MedicalDescriptionLabel?.text = "Test"
//                    return descriptionCell
//
//                } else {
//
//                    let imageCell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageTableViewCell
//
//                    imageCell.MedicalImage?.image = UIImage(named: "20160704_145508.jpg")
//                    return imageCell
//                }
//            }
//        }

        print("Cell for row at: \(indexPath.row)")
        let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as! DescriptionTableViewCell

        if let headerCell = shownCells[indexPath.row] as? YearHeaderCell {

            descriptionCell.MedicalDescriptionLabel?.text = "Year: \(headerCell.year!)"

        } else if let headerCell = shownCells[indexPath.row] as? DayHeaderCell {

            descriptionCell.MedicalDescriptionLabel?.text = "Day: \(headerCell.day!)"
        }

        return descriptionCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        var addRows = false
        var rowsToReload: [Int] = [Int]()

        if let headerCell = shownCells[indexPath.row] as? YearHeaderCell {

            if !headerCell.isExpanded {

                headerCell.isExpanded = true
                rowsToReload = insertDayHeaders(forYear: headerCell.year!, atIndex: indexPath.row + 1)
                addRows = true

            } else {

                headerCell.isExpanded = false
                rowsToReload = removeDayHeaders(atIndex: indexPath.row + 1)
            }

            print(shownCells)

        } else if let headerCell = shownCells[indexPath.row] as? DayHeaderCell {

        }

        var indexPathsToReload: [IndexPath] = [IndexPath]()

        for i in rowsToReload {

            print("index \(i)")
            indexPathsToReload.append(IndexPath(row: i, section: 0))
        }

        print(indexPathsToReload)

        tableView.beginUpdates()

        // TODO: test for empty indexPathsToReload
        if addRows {

            tableView.insertRows(at: indexPathsToReload, with: .fade)

        } else {

            tableView.deleteRows(at: indexPathsToReload, with: .fade)
        }

        tableView.endUpdates()
    }

    func insertDayHeaders(forYear: Int, atIndex: Int) -> [Int] {

        // atIndex will probably be out of bouds if called from last cell. But Swift will take care of that :))
        var startIndex = atIndex
        var rowsAdded: [Int] = [Int]()

        let calendarComponentFlags: Set<Calendar.Component> = [.year, .day]
        var prevDateComponents: DateComponents = Calendar.current.dateComponents(calendarComponentFlags, from: Date(timeIntervalSince1970: 0))

        for healthRecord in healthRecords {

            var dateComponents = Calendar.current.dateComponents(calendarComponentFlags, from: healthRecord.date!)

            if isANewDate(prevDate: prevDateComponents, currentDate: dateComponents, inTermsOf: DateComponent.day) && dateComponents.year == forYear {

                rowsAdded.append(startIndex)
                shownCells.insert(DayHeaderCell(day: dateComponents.day!), at: atIndex)
                startIndex += 1
            }

            prevDateComponents = dateComponents
        }

        return rowsAdded
    }

    func removeDayHeaders(atIndex startIndex: Int) -> [Int] {

        var rowsToRemove: [Int] = [Int]()
        var currentIndex = startIndex

        // atIndex can stay the same because the array becomes smaller every time an item is removed so atIndex will always point to the next item to be potentially removed.

        while currentIndex < shownCells.count && !(shownCells[currentIndex] is YearHeaderCell) {

            rowsToRemove.append(currentIndex)
            currentIndex += 1
        }

        shownCells.removeSubrange(startIndex..<currentIndex)
        
        return rowsToRemove
    }
}

extension TableViewController {

    func printShownCells() {

        for i in 0..<shownCells.count {

            if let yearHeaderCell = shownCells[i] as? YearHeaderCell {

                print("Year: \(yearHeaderCell.year!)")

            } else if let dayHeaderCell = shownCells[i] as? DayHeaderCell {

                print("Day: \(dayHeaderCell.day!)")
            }
        }
    }
}
