//
//  TableViewDataSource.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/29/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

class TableViewDataSource: NSObject {

    var stateController: StateController!

    var shownCells = [Any]()

    var tableView: UITableView!

    init(stateController: StateController) {
        super.init()

        self.stateController = stateController
        initShownCells()
        printShownCells()
    }

    func initShownCells() {

        var prevDate = Date(timeIntervalSince1970: 0)

        for (index, healthRecord) in stateController.healthRecords.enumerated().reversed() {

            if areDatesDifferent(prevDate: prevDate, currentDate: healthRecord.date!, inTermsOf: .year) {

                shownCells.append(YearHeaderCell(indexOfSource: index))
//                print("append at : \(index), for year \(dateComponents.year)")
                prevDate = healthRecord.date!
            }
        }

        expandMostRecentDay()
    }

    func expandMostRecentYear() -> Int {

        guard shownCells.count > 0 else {

            return -1
        }

        if let yearHeader = shownCells[0] as? YearHeaderCell {

            if !yearHeader.isExpanded {

                yearHeader.days = insertDayHeaders(forYearHeader: 0)

                yearHeader.isExpanded = true

                return yearHeader.days

            } else {

                return 0
            }

        }

        return -1
    }

    func expandMostRecentDay() -> Int {

        if expandMostRecentYear() >= 0 {

            if let dayHeader = shownCells[1] as? DayHeaderCell {

                if !dayHeader.isExpanded {

                    dayHeader.entries = insertContentCells(forDayHeader: 1)

                    dayHeader.isExpanded = true

                    return dayHeader.entries
                }

                return 0
            }
        }

        return -1
    }

    // TODO: Write test case for this
    // TODO: Rewrite this function to compare two dates instead
    func areDatesDifferent(prevDate: Date, currentDate: Date, inTermsOf: DateComponent) -> Bool {

        let calendarComponentFlags: Set<Calendar.Component> = [.year, .month, .day]
        let prevDateComponents = Calendar.current.dateComponents(calendarComponentFlags, from: prevDate)
        let currentDateComponents = Calendar.current.dateComponents(calendarComponentFlags, from: currentDate)

        switch inTermsOf {

        case .year:

            if prevDateComponents.year != currentDateComponents.year {

                return true
            }

        case .month:

            if prevDateComponents.year != currentDateComponents.year ||
               prevDateComponents.month != currentDateComponents.month {

                return true
            }

        case .day:

            if prevDateComponents.year != currentDateComponents.year ||
               prevDateComponents.month != currentDateComponents.month ||
               prevDateComponents.day != currentDateComponents.day {
                
                return true
            }
            
        }
        
        return false
    }

    func insertDayHeaders(forYearHeader indexOfYearHeader: Int) -> Int {

        // atIndex will probably be out of bounds if called from last cell. But Swift will take care of that :))
        let indexOfSource = (shownCells[indexOfYearHeader] as! YearHeaderCell).indexOfSource!
        var rowsAdded = 0
        let targetDate = stateController.healthRecords[indexOfSource].date!
        var prevDate = Date(timeIntervalSince1970: 0)

        for (i, healthRecord) in stateController.healthRecords.enumerated().dropLast(stateController.healthRecords.count - indexOfSource - 1).reversed() {

            guard !areDatesDifferent(prevDate: targetDate, currentDate: healthRecord.date!, inTermsOf: .year) else {

                break
            }

            if areDatesDifferent(prevDate: prevDate, currentDate: healthRecord.date!, inTermsOf: .day) {

                shownCells.insert(DayHeaderCell(indexOfSource: i, indexOfYearHeader: indexOfYearHeader), at: indexOfYearHeader + 1 + rowsAdded)
                rowsAdded += 1
            }

            prevDate = healthRecord.date!
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

    func insertContentCells(forDayHeader indexOfDayHeader: Int) -> Int {

        // atIndex will probably be out of bounds if called from last cell. But Swift will take care of that :))
        let indexOfSource = (shownCells[indexOfDayHeader] as! DayHeaderCell).indexOfSource!
        var rowsAdded = 0

        let calendarComponentFlags: Set<Calendar.Component> = [.year, .month, .day]
        let targetDateComponents = Calendar.current.dateComponents(calendarComponentFlags, from: stateController.healthRecords[indexOfSource].date!)

        for (i, healthRecord) in stateController.healthRecords.enumerated().dropLast(stateController.healthRecords.count - indexOfSource - 1).reversed() {

            let dateComponents = Calendar.current.dateComponents(calendarComponentFlags, from: healthRecord.date!)

            guard dateComponents.year == targetDateComponents.year,
                dateComponents.month == targetDateComponents.month,
                dateComponents.day == targetDateComponents.day else {

                break
            }

            shownCells.insert(ContentCell(indexOfSource: i, indexOfDayHeader: indexOfDayHeader), at: indexOfDayHeader + 1 + rowsAdded)

            rowsAdded += 1
        }
        
        return rowsAdded
    }

    func deleteContentRow(atIndex row: Int) -> [IndexPath] {

        let removedItem = shownCells.remove(at: row) as! ContentCell

        removeHealthRecord(at: removedItem.indexOfSource!)
        adjustIndicesOfSource(endingAt: row, by: -1)
        var indexPathsToRemove = removeHeadersIfNeeded(forContentRow: row)
        indexPathsToRemove.append(IndexPath(row: row, section: 0))

        return indexPathsToRemove
    }

    func removeHeadersIfNeeded(forContentRow indexOfContentRow: Int) -> [IndexPath] {

        var indexPathsToRemove = [IndexPath]()

        let indexOfDayHeader = decrementContentCellCountInHeader(from: indexOfContentRow - 1)
        let dayHeaderCell = shownCells[indexOfDayHeader] as! DayHeaderCell

        if dayHeaderCell.entries == 0 {

            shownCells.remove(at: indexOfDayHeader)
            indexPathsToRemove.append(IndexPath(row: indexOfDayHeader, section: 0))

            let indexOfYearHeader = decrementDayHeaderCountInYearHeader(from: indexOfDayHeader - 1)
            let yearHeaderCell = shownCells[indexOfYearHeader] as! YearHeaderCell

            if yearHeaderCell.days == 0 {

                shownCells.remove(at: indexOfYearHeader)
                indexPathsToRemove.append(IndexPath(row: indexOfYearHeader, section: 0))
            }
        }

        return indexPathsToRemove
    }

    func removeHealthRecord(at index: Int) {

        stateController.healthRecords.remove(at: index)
    }

    func adjustIndicesOfSource(endingAt endRow: Int, by: Int) {

        for i in 0..<endRow {

            let shownCell = shownCells[i] as! VisibleCell

            shownCell.indexOfSource = shownCell.indexOfSource + by
        }
    }

    func decrementContentCellCountInHeader(from index: Int) -> Int {

        var indexOfDayHeader = index

        while !(shownCells[indexOfDayHeader] is DayHeaderCell) {

            indexOfDayHeader -= 1
        }

        let dayHeaderCell = shownCells[indexOfDayHeader] as! DayHeaderCell

        dayHeaderCell.entries = dayHeaderCell.entries - 1

        return indexOfDayHeader
    }

    func decrementDayHeaderCountInYearHeader(from index: Int) -> Int {

        var indexOfYearHeader = index

        while !(shownCells[indexOfYearHeader] is YearHeaderCell) {

            indexOfYearHeader -= 1
        }

        let yearHeaderCell = shownCells[indexOfYearHeader] as! YearHeaderCell

        yearHeaderCell.days = yearHeaderCell.days - 1
        
        return indexOfYearHeader
    }

    func addNewEntry(newEntry: HealthCondition) {

        // There should be three cases at this point:
        //
        // 1 - Health Record is empty, so this is the very first entry
        //
        // 2 - There is some old data, but this new entry is for a different date,
        //     so new headers need to be created
        //
        // 3 - There is some old data, and this new entry is for the same day as the
        //     most recent entry

        var rowsAdded = 1
        var addedAtIndex = 0

        if shownCells.count == 0 {

            initShownCells()

        } else {

            let mostRecentEntry = shownCells[0] as! YearHeaderCell
            let mostRecentDate = stateController.healthRecords[mostRecentEntry.indexOfSource].date!
            let indexOfSource = stateController.healthRecords.count - 1

            if areDatesDifferent(prevDate: mostRecentDate, currentDate: newEntry.date!, inTermsOf: DateComponent.year) {

                shownCells.insert(YearHeaderCell(indexOfSource: indexOfSource), at: 0)
                shownCells.insert(DayHeaderCell(indexOfSource: indexOfSource, indexOfYearHeader: 0), at: 1)
                shownCells.insert(ContentCell(indexOfSource: indexOfSource, indexOfDayHeader: 1), at: 2)

                let yearHeader = shownCells[0] as! YearHeaderCell
                yearHeader.days = yearHeader.days + 1
                yearHeader.isExpanded = true

                rowsAdded += 2

            } else if areDatesDifferent(prevDate: mostRecentDate, currentDate: newEntry.date!, inTermsOf: .day) {

                rowsAdded += expandMostRecentYear()

                shownCells.insert(DayHeaderCell(indexOfSource: indexOfSource, indexOfYearHeader: 0), at: 1)
                shownCells.insert(ContentCell(indexOfSource: indexOfSource, indexOfDayHeader: 1), at: 2)

                let yearHeader = shownCells[0] as! YearHeaderCell
                yearHeader.days = yearHeader.days + 1
                yearHeader.isExpanded = true
                yearHeader.indexOfSource = yearHeader.indexOfSource + 1

                rowsAdded += 1

            } else {

                rowsAdded += expandMostRecentDay()

                shownCells.insert(ContentCell(indexOfSource: indexOfSource, indexOfDayHeader: 1), at: 2)

                let yearHeader = shownCells[0] as! YearHeaderCell
                yearHeader.indexOfSource = yearHeader.indexOfSource + 1

                let dayHeader = shownCells[1] as! DayHeaderCell
                dayHeader.indexOfSource = dayHeader.indexOfSource + 1

                printShownCells()
            }

            let dayHeader = shownCells[1] as! DayHeaderCell
            dayHeader.entries = dayHeader.entries + 1
            dayHeader.isExpanded = true
        }

        var indexPaths = [IndexPath]()

        for i in 0..<rowsAdded {

            indexPaths.append(IndexPath(row: i, section: 0))
        }

        tableView.reloadData()

    }
}

extension TableViewDataSource: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return shownCells.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if let contentCell = shownCells[indexPath.row] as? ContentCell {

            if stateController.healthRecords[contentCell.indexOfSource!] is HealthImage {

                if contentCell.isExpanded {

                    return 220

                } else {

                    return 60
                }

            } else if stateController.healthRecords[contentCell.indexOfSource!] is HealthDescription {

                if contentCell.isExpanded {

                    return 120

                } else {

                    return 60
                }

            } else {

                return 60
            }

        } else {

            return 60
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        print("cellForRowAt: \(indexPath.row)")
        
        var cell: UITableViewCell!

        if let yearHeaderCell = shownCells[indexPath.row] as? YearHeaderCell {

            let yearCell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! HeaderViewCell

            yearCell.headerLabel?.text = "Year: \(stateController.healthRecords[yearHeaderCell.indexOfSource!].date!)"

            cell = yearCell

        } else if let dayHeaderCell = shownCells[indexPath.row] as? DayHeaderCell {

            let dayCell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! HeaderViewCell

            dayCell.headerLabel?.text = "Day: \(stateController.healthRecords[dayHeaderCell.indexOfSource!].date!)"

            cell = dayCell

        } else if let contentCell = shownCells[indexPath.row] as? ContentCell {

            let healthCondition = stateController.healthRecords[contentCell.indexOfSource!]

            if let healthDescription = healthCondition as? HealthDescription {

                let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as! DescriptionTableViewCell

                descriptionCell.MedicalDescriptionLabel?.text = "Day: \(healthDescription.condition!)"

                cell = descriptionCell

            } else if let healthImage = healthCondition as? HealthImage {

                let imageCell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageTableViewCell

                imageCell.medicalImage?.image = healthImage.image

                cell = imageCell
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        CATransaction.begin()

        var addingRows = false
        var rowsToAddOrRemove = 0

        if let yearHeaderCell = shownCells[indexPath.row] as? YearHeaderCell {

            if !yearHeaderCell.isExpanded {

                yearHeaderCell.isExpanded = true

                yearHeaderCell.days = insertDayHeaders(forYearHeader: indexPath.row)

                rowsToAddOrRemove = yearHeaderCell.days!
                addingRows = true

            } else {

                yearHeaderCell.isExpanded = false

                rowsToAddOrRemove = yearHeaderCell.days! + numOfContentRows(startIndex: indexPath.row+1, numOfDayHeaders: yearHeaderCell.days!)

                yearHeaderCell.days = 0
                shownCells.removeSubrange(indexPath.row+1..<indexPath.row+1+rowsToAddOrRemove)
            }

        } else if let dayHeaderCell = shownCells[indexPath.row] as? DayHeaderCell {

            if !dayHeaderCell.isExpanded {

                dayHeaderCell.isExpanded = true

                dayHeaderCell.entries = insertContentCells(forDayHeader: indexPath.row)

                rowsToAddOrRemove = dayHeaderCell.entries!
                addingRows = true

            } else {

                dayHeaderCell.isExpanded = false
                shownCells.removeSubrange(indexPath.row+1..<indexPath.row+1+dayHeaderCell.entries!)
                rowsToAddOrRemove = dayHeaderCell.entries!
                dayHeaderCell.entries = 0
            }

        } else if let contentCell = shownCells[indexPath.row] as? ContentCell {

            let visibleCell = tableView.cellForRow(at: indexPath) as! UITableViewCell

            if contentCell.isExpanded == true {

                contentCell.isExpanded = false

                // Hide the content only after animation has completed
                CATransaction.setCompletionBlock({

                    visibleCell.hideExtraContent()
                })

            } else {

                contentCell.isExpanded = true

                // Show the content before the expansion of the cell reveals the content
                visibleCell.showExtraContent()
            }

            if let cell = tableView.cellForRow(at: indexPath) as? DescriptionTableViewCell {

                print("description Cell selected")


            }

            rowsToAddOrRemove = 0
        }

        var indexPathsToReload: [IndexPath] = [IndexPath]()

        if rowsToAddOrRemove > 0 {

            for i in indexPath.row+1..<indexPath.row+1+rowsToAddOrRemove {

                print("index \(i)")
                indexPathsToReload.append(IndexPath(row: i, section: 0))
            }

        }

        tableView.beginUpdates()

        if rowsToAddOrRemove > 0 {

            if addingRows {

                tableView.insertRows(at: indexPathsToReload, with: .fade)

            } else {

                tableView.deleteRows(at: indexPathsToReload, with: .fade)
            }
        } else {

//            tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .fade)
//            print("reload rows at: \(indexPath.row)")
        }

        tableView.endUpdates()

        CATransaction.commit()
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        if shownCells[indexPath.row] is ContentCell {

            return true
        }

        return false
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let update = UITableViewRowAction(style: .normal, title: "Update") { action, index in

        }

        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in

            let indexPaths = self.deleteContentRow(atIndex: indexPath.row)

            tableView.beginUpdates()
            tableView.deleteRows(at: indexPaths, with: .fade)
            tableView.endUpdates()
        }

        return [delete, update]
    }
}

// Helper functions, not essential to the app

extension TableViewDataSource {

    func printShownCells() {

        for i in 0..<shownCells.count {

            if let yearHeaderCell = shownCells[i] as? YearHeaderCell {

                print("Year: \(stateController.healthRecords[yearHeaderCell.indexOfSource!].date!)")

            } else if let dayHeaderCell = shownCells[i] as? DayHeaderCell {

                print("Day: \(stateController.healthRecords[dayHeaderCell.indexOfSource!].date!)")

            } else if let contentCell = shownCells[i] as? ContentCell {

                print("Content: \(stateController.healthRecords[contentCell.indexOfSource!].date!)")
            }
        }
    }
}

