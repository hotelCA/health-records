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

    var healthRecords = [HealthCondition]()

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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        loadHealthRecord()

        for i in 0..<healthRecords.count {

            print(healthRecords[i].date)
        }

        initShownCells()
        printShownCells()
    }

    func loadHealthRecord() {

        for i in 1..<80 {

            var index = i / 4

            healthRecords.append(HealthCondition(timeOfCondition: Date(timeIntervalSinceNow: TimeInterval(3*index*OneMonth + i)), condition: ConditionEnum.pain))
        }
    }

    func initShownCells() {

        let calendarComponentFlags: Set<Calendar.Component> = [.year]
        var prevDateComponents: DateComponents = Calendar.current.dateComponents(calendarComponentFlags, from: Date(timeIntervalSince1970: 0))

        for (index, healthRecord) in healthRecords.enumerated() {

            let dateComponents = Calendar.current.dateComponents(calendarComponentFlags, from: healthRecord.date!)

            if isANewDate(prevDate: prevDateComponents, currentDate: dateComponents, inTermsOf: DateComponent.year) {

                shownCells.append(YearHeaderCell(indexOfSource: index))
            }

            prevDateComponents = dateComponents
        }
    }

    // TODO: Write test case for this
    // TODO: Rewrite this function to compare two dates instead
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

        let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as! DescriptionTableViewCell

        if let yearHeaderCell = shownCells[indexPath.row] as? YearHeaderCell {

            descriptionCell.MedicalDescriptionLabel?.text = "Year: \(healthRecords[yearHeaderCell.indexOfSource!].date!)"

        } else if let dayHeaderCell = shownCells[indexPath.row] as? DayHeaderCell {

            descriptionCell.MedicalDescriptionLabel?.text = "Day: \(healthRecords[dayHeaderCell.indexOfSource!].date!)"

        } else if let contentCell = shownCells[indexPath.row] as? ContentCell {

            descriptionCell.MedicalDescriptionLabel?.text = "Day: \(contentCell.healthCondition!.condition!)"
        }

        return descriptionCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        var addRows = false
        var rowsToModify = 0

        if let yearHeaderCell = shownCells[indexPath.row] as? YearHeaderCell {

            if !yearHeaderCell.isExpanded {

                yearHeaderCell.isExpanded = true

                yearHeaderCell.days = insertDayHeaders(atSourceIndex: yearHeaderCell.indexOfSource!, atIndex: indexPath.row + 1)

                rowsToModify = yearHeaderCell.days!
                addRows = true

            } else {

                yearHeaderCell.isExpanded = false

                rowsToModify = yearHeaderCell.days! + numOfContentRows(startIndex: indexPath.row+1, numOfDayHeaders: yearHeaderCell.days!)

                yearHeaderCell.days = 0
                shownCells.removeSubrange(indexPath.row+1..<indexPath.row+1+rowsToModify)
            }

        } else if let dayHeaderCell = shownCells[indexPath.row] as? DayHeaderCell {

            if !dayHeaderCell.isExpanded {

                dayHeaderCell.isExpanded = true

                dayHeaderCell.entries = insertContentCells(atSourceIndex: dayHeaderCell.indexOfSource!, atIndex: indexPath.row + 1)

                rowsToModify = dayHeaderCell.entries!
                addRows = true

            } else {

                dayHeaderCell.isExpanded = false
                shownCells.removeSubrange(indexPath.row+1..<indexPath.row+1+dayHeaderCell.entries!)
                rowsToModify = dayHeaderCell.entries!
                dayHeaderCell.entries = 0
            }
        }

        var indexPathsToReload: [IndexPath] = [IndexPath]()

        for i in indexPath.row+1..<indexPath.row+1+rowsToModify {

            print("index \(i)")
            indexPathsToReload.append(IndexPath(row: i, section: 0))
        }

        tableView.beginUpdates()

        // TODO: test for empty indexPathsToReload
        if addRows {

            tableView.insertRows(at: indexPathsToReload, with: .fade)

        } else {

            tableView.deleteRows(at: indexPathsToReload, with: .fade)
        }

        tableView.endUpdates()

    }

    func insertDayHeaders(atSourceIndex: Int, atIndex: Int) -> Int {

        // atIndex will probably be out of bounds if called from last cell. But Swift will take care of that :))
        var rowsAdded = 0
        let targetYear = Calendar.current.dateComponents([.year], from: healthRecords[atSourceIndex].date!)

        let calendarComponentFlags: Set<Calendar.Component> = [.year, .day]
        var prevDateComponents: DateComponents = Calendar.current.dateComponents(calendarComponentFlags, from: Date(timeIntervalSince1970: 0))

        for (i, healthRecord) in healthRecords.enumerated().dropFirst(atSourceIndex) {

            let dateComponents = Calendar.current.dateComponents(calendarComponentFlags, from: healthRecord.date!)

            guard (dateComponents.year == targetYear.year) else {

                break
            }

            if isANewDate(prevDate: prevDateComponents, currentDate: dateComponents, inTermsOf: DateComponent.day) {

                shownCells.insert(DayHeaderCell(indexOfSource: i), at: atIndex + rowsAdded)
                rowsAdded += 1
            }

            prevDateComponents = dateComponents
        }

        return rowsAdded
    }

    func numOfContentRows(startIndex: Int, numOfDayHeaders: Int) -> Int {

        var rows = 0

        for i in startIndex..<startIndex + numOfDayHeaders {

            if let dayHeaderCell = shownCells[i + rows] as? DayHeaderCell {

                rows += dayHeaderCell.entries!
            }
        }

        return rows
    }

    func insertContentCells(atSourceIndex: Int, atIndex: Int) -> Int {

        // atIndex will probably be out of bounds if called from last cell. But Swift will take care of that :))
        print("atSource: \(atSourceIndex), atIndex: \(atIndex)")
        var rowsAdded = 0

        let calendarComponentFlags: Set<Calendar.Component> = [.year, .month, .day]
        let targetDateComponents = Calendar.current.dateComponents(calendarComponentFlags, from: healthRecords[atSourceIndex].date!)

        for (i, healthRecord) in healthRecords.enumerated().dropFirst(atSourceIndex) {

            let dateComponents = Calendar.current.dateComponents(calendarComponentFlags, from: healthRecord.date!)

            guard dateComponents.year == targetDateComponents.year,
                  dateComponents.month == targetDateComponents.month,
                  dateComponents.day == targetDateComponents.day else {

                break
            }

            shownCells.insert(ContentCell(healthCondition: healthRecord,indexOfSource: i), at: atIndex + rowsAdded)

            rowsAdded += 1
        }
        
        return rowsAdded
    }
}

extension TableViewController {

    func printShownCells() {

        for i in 0..<shownCells.count {

            if let yearHeaderCell = shownCells[i] as? YearHeaderCell {

                print("Year: \(healthRecords[yearHeaderCell.indexOfSource!].date)")

            } else if let dayHeaderCell = shownCells[i] as? DayHeaderCell {

                print("Day: \(healthRecords[dayHeaderCell.indexOfSource!].date!)")
            }
        }
    }
}
