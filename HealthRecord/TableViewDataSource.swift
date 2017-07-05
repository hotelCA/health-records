//
//  TableViewDataSource.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/29/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

class TableViewDataSource: NSObject {

    var healthRecords: [HealthCondition]!

    var shownCells = [Any]()

    init(healthRecords: [HealthCondition]) {
        super.init()

        self.healthRecords = healthRecords
        initShownCells()
        printShownCells()
    }

    func initShownCells() {

        let calendarComponentFlags: Set<Calendar.Component> = [.year]
        var prevDateComponents: DateComponents = Calendar.current.dateComponents(calendarComponentFlags, from: Date(timeIntervalSince1970: 0))

        for (index, healthRecord) in healthRecords.enumerated().reversed() {

            let dateComponents = Calendar.current.dateComponents(calendarComponentFlags, from: healthRecord.date!)

            if isANewDate(prevDate: prevDateComponents, currentDate: dateComponents, inTermsOf: DateComponent.year) {

                shownCells.append(YearHeaderCell(indexOfSource: index))
//                print("append at : \(index), for year \(dateComponents.year)")
                prevDateComponents = dateComponents
            }
        }

        self.expandMostRecentDay()
    }

    func expandMostRecentYear() -> Bool {

        guard shownCells.count > 0 else {

            return false
        }

        if let yearHeader = shownCells[0] as? YearHeaderCell {

            if !yearHeader.isExpanded {

                yearHeader.days = self.insertDayHeaders(atSourceIndex: yearHeader.indexOfSource, atIndex: 1)

                yearHeader.isExpanded = true
            }

            return true
        }

        return false
    }

    func expandMostRecentDay() -> Bool {

        if self.expandMostRecentYear() {

            if let dayHeader = shownCells[1] as? DayHeaderCell {

                if !dayHeader.isExpanded {

                    dayHeader.entries = self.insertContentCells(atSourceIndex: dayHeader.indexOfSource, atIndex: 2)

                    dayHeader.isExpanded = true
                }

                return true
            }
        }

        return false
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

    func insertDayHeaders(atSourceIndex: Int, atIndex: Int) -> Int {

        // atIndex will probably be out of bounds if called from last cell. But Swift will take care of that :))
        var rowsAdded = 0
        let targetYear = Calendar.current.dateComponents([.year], from: healthRecords[atSourceIndex].date!)

        let calendarComponentFlags: Set<Calendar.Component> = [.year, .day]
        var prevDateComponents: DateComponents = Calendar.current.dateComponents(calendarComponentFlags, from: Date(timeIntervalSince1970: 0))

        for (i, healthRecord) in healthRecords.enumerated().dropLast(healthRecords.count - atSourceIndex - 1).reversed() {

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
//        print("atSource: \(atSourceIndex), atIndex: \(atIndex)")
        var rowsAdded = 0

        let calendarComponentFlags: Set<Calendar.Component> = [.year, .month, .day]
        let targetDateComponents = Calendar.current.dateComponents(calendarComponentFlags, from: healthRecords[atSourceIndex].date!)

        for (i, healthRecord) in healthRecords.enumerated().dropLast(healthRecords.count - atSourceIndex - 1).reversed() {

            let dateComponents = Calendar.current.dateComponents(calendarComponentFlags, from: healthRecord.date!)

            guard dateComponents.year == targetDateComponents.year,
                dateComponents.month == targetDateComponents.month,
                dateComponents.day == targetDateComponents.day else {

                    break
            }

            shownCells.insert(ContentCell(healthCondition: healthRecord,indexOfSource: i), at: atIndex + rowsAdded)

//            print("date of inserted cell: \(healthRecord.date!)")
            rowsAdded += 1
        }
        
        return rowsAdded
    }

    func deleteRowsForContentRow(atIndex index: Int) -> [IndexPath] {

        var indexPaths = [IndexPath(row: index, section: 0)]

        let removedItem = shownCells.remove(at: index) as! ContentCell

        self.removeHealthRecord(at: removedItem.indexOfSource!)
        self.decrementIndicesOfSource(endingAt: index)

        let indexOfDayHeader = self.decrementContentCellCountInHeader(from: index - 1)
        let dayHeaderCell = shownCells[indexOfDayHeader] as! DayHeaderCell

        if dayHeaderCell.entries == 0 {

            self.removeHeader(at: indexOfDayHeader)
            indexPaths.append(IndexPath(row: indexOfDayHeader, section: 0))
            print("remove day header")

            let indexOfYearHeader = self.decrementDayHeaderCountInYearHeader(from: indexOfDayHeader - 1)

            let yearHeaderCell = shownCells[indexOfYearHeader] as! YearHeaderCell

            if yearHeaderCell.days == 0 {

                self.removeHeader(at: indexOfYearHeader)
                indexPaths.append(IndexPath(row: indexOfYearHeader, section: 0))
                print("remove year header")
            }
        }

        return indexPaths
    }

    func removeHealthRecord(at index: Int) {

        healthRecords.remove(at: index)
    }

    func decrementIndicesOfSource(endingAt endIndex: Int) {

        for i in 0..<endIndex {

            if let contentCell = shownCells[i] as? VisibleCell {

                contentCell.indexOfSource = contentCell.indexOfSource - 1
            }
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

    func removeHeader(at index: Int) {

        shownCells.remove(at: index)
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

            if let healthImageCell = contentCell.healthCondition as? HealthImage {

                if contentCell.isExpanded {

                    return 220

                } else {

                    return 60
                }

            } else if let healthDescriptionCell = contentCell.healthCondition as? HealthDescription{

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

            yearCell.headerLabel?.text = "Year: \(healthRecords[yearHeaderCell.indexOfSource!].date!)"

            cell = yearCell

        } else if let dayHeaderCell = shownCells[indexPath.row] as? DayHeaderCell {

            let dayCell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! HeaderViewCell

            dayCell.headerLabel?.text = "Day: \(healthRecords[dayHeaderCell.indexOfSource!].date!)"

            cell = dayCell

        } else if let contentCell = shownCells[indexPath.row] as? ContentCell {

            if let healthDescription = contentCell.healthCondition as? HealthDescription {

                let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as! DescriptionTableViewCell

                descriptionCell.MedicalDescriptionLabel?.text = "Day: \(healthDescription.condition!)"

                cell = descriptionCell

            } else if let healthImage = contentCell.healthCondition as? HealthImage {

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

                yearHeaderCell.days = insertDayHeaders(atSourceIndex: yearHeaderCell.indexOfSource!, atIndex: indexPath.row + 1)

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

                dayHeaderCell.entries = insertContentCells(atSourceIndex: dayHeaderCell.indexOfSource!, atIndex: indexPath.row + 1)

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

            let indexPaths = self.deleteRowsForContentRow(atIndex: indexPath.row)

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

                print("Year: \(healthRecords[yearHeaderCell.indexOfSource!].date)")

            } else if let dayHeaderCell = shownCells[i] as? DayHeaderCell {

                print("Day: \(healthRecords[dayHeaderCell.indexOfSource!].date!)")
            }
        }
    }
}

