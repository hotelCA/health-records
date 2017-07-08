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

        let indexOfLatestYearHeader = 0
        let indexOfLatestDayHeader = 1

        showYearHeaders()
        expandYearHeader(atIndex: indexOfLatestYearHeader)
        expandDayHeader(atIndex: indexOfLatestDayHeader)
    }

    func showYearHeaders() {

        var prevDate = Date(timeIntervalSince1970: 0)

        for (index, healthRecord) in stateController.healthRecords.enumerated().reversed() {

            if areDatesDifferent(prevDate: prevDate, currentDate: healthRecord.date!, forComponents: [.year]) {

                shownCells.append(YearHeaderCell(indexOfSource: index))
                prevDate = healthRecord.date!
            }
        }
    }

    // TODO: throw error if argument not for year header
    func expandYearHeader(atIndex yearHeaderIndex: Int) -> Int {

        let yearHeader = shownCells[yearHeaderIndex] as! YearHeaderCell

        guard !yearHeader.isExpanded else {

            return 0
        }

        let targetDate = stateController.healthRecords[yearHeader.indexOfSource!].date!
        var prevDate = Date(timeIntervalSince1970: 0)

        for (i, healthRecord) in stateController.healthRecords.enumerated().dropLast(stateController.healthRecords.count - yearHeader.indexOfSource! - 1).reversed() {

            guard !areDatesDifferent(prevDate: targetDate, currentDate: healthRecord.date!, forComponents: [.year]) else {

                break
            }

            if areDatesDifferent(prevDate: prevDate, currentDate: healthRecord.date!, forComponents: [.day]) {

                shownCells.insert(DayHeaderCell(indexOfSource: i, indexOfYearHeader: yearHeaderIndex), at: yearHeaderIndex+1+yearHeader.days)

                yearHeader.days = yearHeader.days + 1

                prevDate = healthRecord.date!
            }
        }

        yearHeader.isExpanded = true

        return yearHeader.days
    }

    // TODO: throw error if argument not for year header
    func collapseYearHeader(atIndex yearHeaderIndex: Int) -> Int {

        let yearHeader = shownCells[yearHeaderIndex] as! YearHeaderCell

        guard yearHeader.isExpanded else {

            return 0
        }

        let rowsCollapsed = yearHeader.days! + collapseDayHeaders(forYearHeader: yearHeaderIndex)

        let firstDayHeaderIndex = yearHeaderIndex + 1

        shownCells.removeSubrange(firstDayHeaderIndex..<firstDayHeaderIndex+yearHeader.days!)

        yearHeader.isExpanded = false
        yearHeader.days = 0

        return rowsCollapsed
    }

    // TODO: throw error if argument not for year header
    func collapseDayHeaders(forYearHeader yearHeaderIndex: Int) -> Int {

        let yearHeader = shownCells[yearHeaderIndex] as! YearHeaderCell

        guard yearHeader.isExpanded else {

            return 0
        }

        let firstDayHeaderIndex = yearHeaderIndex + 1
        var rowsCollapsed = 0

        for dayHeaderIndex in firstDayHeaderIndex..<firstDayHeaderIndex+yearHeader.days! {

            rowsCollapsed += collapseDayHeader(atIndex: dayHeaderIndex)
        }

        print("rows collapsed 1: \(rowsCollapsed)")
        return rowsCollapsed
    }

    // TODO: throw exception if argument not for day header
    func expandDayHeader(atIndex dayHeaderIndex: Int) -> Int {

        let dayHeader = shownCells[dayHeaderIndex] as! DayHeaderCell

        guard !dayHeader.isExpanded else {

            return 0
        }

        let targetDate = stateController.healthRecords[dayHeader.indexOfSource!].date!

        for (i, healthRecord) in stateController.healthRecords.enumerated().dropLast(stateController.healthRecords.count - dayHeader.indexOfSource! - 1).reversed() {

            guard !areDatesDifferent(prevDate: targetDate, currentDate: healthRecord.date!, forComponents: [.year, .month, .day]) else {

                break
            }

            shownCells.insert(ContentCell(indexOfSource: i, indexOfDayHeader: dayHeaderIndex), at: dayHeaderIndex+1+dayHeader.entries)

            dayHeader.entries = dayHeader.entries + 1
        }

        dayHeader.isExpanded = true

        return dayHeader.entries
    }

    // TODO: throw exception if argument not for day header
    func collapseDayHeader(atIndex dayHeaderIndex: Int) -> Int {
        
        let dayHeader = shownCells[dayHeaderIndex] as! DayHeaderCell
        
        guard dayHeader.isExpanded else {
            
            return 0
        }
        
        let rowsCollapsed = dayHeader.entries!
        
        shownCells.removeSubrange(dayHeaderIndex+1..<dayHeaderIndex+1+rowsCollapsed)
        
        dayHeader.isExpanded = false
        dayHeader.entries = 0
        
        return rowsCollapsed
    }

    func expandMostRecentYear() -> Int {

        guard shownCells.count > 0 else {

            return -1
        }

        if let yearHeader = shownCells[0] as? YearHeaderCell {

            if !yearHeader.isExpanded {

                return expandYearHeader(atIndex: 0)

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

                    return expandDayHeader(atIndex: 1)
                }

                return 0
            }
        }

        return -1
    }

    // TODO: Write test case for this
    // TODO: Rewrite this function to compare two dates instead
    func areDatesDifferent(prevDate: Date, currentDate: Date, forComponents targetComponents: [DateComponent]) -> Bool {

        let components: Set<Calendar.Component> = [.year, .month, .day]
        let prevDateComponents = Calendar.current.dateComponents(components, from: prevDate)
        let currentDateComponents = Calendar.current.dateComponents(components, from: currentDate)

        if targetComponents.contains(.year) {

            if prevDateComponents.year != currentDateComponents.year {

                return true
            }
        }

        if targetComponents.contains(.month) {

            if prevDateComponents.month != currentDateComponents.month {

                return true
            }
        }

        if targetComponents.contains(.day) {

            if prevDateComponents.day != currentDateComponents.day {

                return true
            }
        }

        return false
    }

    func deleteContentRow(atIndex row: Int) -> [IndexPath] {

        let removedItem = shownCells.remove(at: row) as! ContentCell

        removeHealthRecord(at: removedItem.indexOfSource!)
        adjustIndicesOfSource(endingAt: row, by: -1)
        var indexPathsToRemove = removeHeadersIfNeeded(startAtDayHeader: removedItem.indexOfDayHeader!)
        indexPathsToRemove.append(IndexPath(row: row, section: 0))

        return indexPathsToRemove
    }

    func removeHeadersIfNeeded(startAtDayHeader indexOfDayHeader: Int) -> [IndexPath] {

        var indexPathsToRemove = [IndexPath]()

        let dayHeaderCell = shownCells[indexOfDayHeader] as! DayHeaderCell
        dayHeaderCell.entries = dayHeaderCell.entries - 1

        if dayHeaderCell.entries == 0 {

            shownCells.remove(at: indexOfDayHeader)
            indexPathsToRemove.append(IndexPath(row: indexOfDayHeader, section: 0))

            let indexOfYearHeader = (shownCells[indexOfDayHeader] as! DayHeaderCell).indexOfYearHeader!
            let yearHeaderCell = shownCells[indexOfYearHeader] as! YearHeaderCell
            yearHeaderCell.days = yearHeaderCell.days - 1

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

        if shownCells.count == 0 {

            initShownCells()

        } else {

            let mostRecentEntry = shownCells[0] as! YearHeaderCell
            let mostRecentDate = stateController.healthRecords[mostRecentEntry.indexOfSource].date!
            let indexOfSource = stateController.healthRecords.count - 1

            if areDatesDifferent(prevDate: mostRecentDate, currentDate: newEntry.date!, forComponents: [.year]) {

                shownCells.insert(YearHeaderCell(indexOfSource: indexOfSource), at: 0)
                shownCells.insert(DayHeaderCell(indexOfSource: indexOfSource, indexOfYearHeader: 0), at: 1)
                shownCells.insert(ContentCell(indexOfSource: indexOfSource, indexOfDayHeader: 1), at: 2)

                let yearHeader = shownCells[0] as! YearHeaderCell
                yearHeader.days = yearHeader.days + 1
                yearHeader.isExpanded = true

                rowsAdded += 2

            } else if areDatesDifferent(prevDate: mostRecentDate, currentDate: newEntry.date!, forComponents: [.day]) {

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
    }

    func expandOrCollapseYearHeader(yearHeaderIndex: Int) -> Int {

        let yearHeader = shownCells[yearHeaderIndex] as! YearHeaderCell

        if !yearHeader.isExpanded {

            return expandYearHeader(atIndex: yearHeaderIndex)

        } else {

            return -collapseYearHeader(atIndex: yearHeaderIndex)
        }
    }

    func expandOrCollapseDayHeader(dayHeaderIndex: Int) -> Int {

        let dayHeader = shownCells[dayHeaderIndex] as! DayHeaderCell

        if !dayHeader.isExpanded {

            return expandDayHeader(atIndex: dayHeaderIndex)

        } else {

            return -collapseDayHeader(atIndex: dayHeaderIndex)
        }
    }

    func expandOrCollapseContent(contentIndex: Int) -> Bool {

        let content = shownCells[contentIndex] as! ContentCell

        if content.isExpanded == true {

            content.isExpanded = false

            return false

        } else {

            content.isExpanded = true

            return true
        }
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

        var rowsToAddOrRemove = 0

        if shownCells[indexPath.row] is YearHeaderCell {

            rowsToAddOrRemove = expandOrCollapseYearHeader(yearHeaderIndex: indexPath.row)

        } else if shownCells[indexPath.row] is DayHeaderCell {

            rowsToAddOrRemove = expandOrCollapseDayHeader(dayHeaderIndex: indexPath.row)

        } else if shownCells[indexPath.row] is ContentCell {

            let expandContent = expandOrCollapseContent(contentIndex: indexPath.row)
            let visibleCell = tableView.cellForRow(at: indexPath)!

            if expandContent == false {

                // Hide the content AFTER animation has completed
                CATransaction.setCompletionBlock({

                    visibleCell.hideExtraContent()
                })

            } else {

                // Show the content BEFORE the expansion of the cell reveals the content
                visibleCell.showExtraContent()
            }
        }

        var indexPaths: [IndexPath] = [IndexPath]()

        if rowsToAddOrRemove != 0 {

            for i in indexPath.row+1..<indexPath.row+1+abs(rowsToAddOrRemove) {

                indexPaths.append(IndexPath(row: i, section: 0))
            }
        }

        tableView.beginUpdates()

        if rowsToAddOrRemove > 0 {

            tableView.insertRows(at: indexPaths, with: .fade)

        } else if rowsToAddOrRemove < 0 {

            tableView.deleteRows(at: indexPaths, with: .fade)
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

