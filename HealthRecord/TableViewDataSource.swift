//
//  TableViewDataSource.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/29/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

class TableViewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var stateController: StateController!

    var shownCells = [Any]()

    var tableView: UITableView!

    init(stateController: StateController) {
        super.init()

        self.stateController = stateController
        initShownCells()
        printShownCells()
    }

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return shownCells.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        var height = CGFloat(50)

        if let contentCell = shownCells[indexPath.row] as? ContentCell {

            if stateController.healthRecords[contentCell.indexOfSource!] is HealthImage {

                if contentCell.isExpanded {

                    height = 220
                }

            } else if stateController.healthRecords[contentCell.indexOfSource!] is HealthDescription {

                if contentCell.isExpanded {

                    height = 120
                }
            }
        }

        return height
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell!

        if let yearHeaderCell = shownCells[indexPath.row] as? YearHeaderCell {

            let yearCell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! HeaderViewCell

            yearCell.headerLabel?.text = "Year: \(HealthCondition.generateStringFromDateInLocalTimezone(date: stateController.healthRecords[yearHeaderCell.indexOfSource!].date))"

            if stateController.mode == .printing {

                yearCell.loadPrintMode()
            }

            cell = yearCell

        } else if let dayHeaderCell = shownCells[indexPath.row] as? DayHeaderCell {

            let dayCell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! HeaderViewCell

            dayCell.headerLabel?.text = "Day: \(HealthCondition.generateStringFromDateInLocalTimezone(date: stateController.healthRecords[dayHeaderCell.indexOfSource!].date))"

            if stateController.mode == .printing {

                dayCell.loadPrintMode()
            }

            cell = dayCell

        } else if let contentCell = shownCells[indexPath.row] as? ContentCell {

            let healthCondition = stateController.healthRecords[contentCell.indexOfSource!]

            if let healthDescription = healthCondition as? HealthDescription {

                let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as! DescriptionTableViewCell

                descriptionCell.MedicalDescriptionLabel?.text = "Day: \(healthDescription.condition!)"

                if stateController.mode == .printing {

                    descriptionCell.loadPrintMode()
                }

                cell = descriptionCell

            } else if let healthImage = healthCondition as? HealthImage {

                let imageCell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageTableViewCell

                imageCell.medicalImage?.image = healthImage.image
                
                if stateController.mode == .printing {

                    imageCell.loadPrintMode()
                }

                cell = imageCell
            }

            contentCell.isExpanded ? cell.showExtraContent() : cell.hideExtraContent()
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

        if let content = shownCells[indexPath.row] as? ContentCell {
            
            if !content.isExpanded {
                
                return true
            }
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

extension TableViewDataSource {

    fileprivate func initShownCells() {

        let indexOfLatestYearHeader = 0
        let indexOfLatestDayHeader = 1

        showYearHeaders()
        _ = expandYearHeader(atIndex: indexOfLatestYearHeader)
        _ = expandDayHeader(atIndex: indexOfLatestDayHeader)
    }

    fileprivate func showYearHeaders() {

        var prevDate = Date(timeIntervalSince1970: 0)

        for (index, healthRecord) in stateController.healthRecords.enumerated().reversed() {

            if areDatesDifferent(prevDate: prevDate, currentDate: healthRecord.date!, forComponents: [.year]) {

                shownCells.append(YearHeaderCell(indexOfSource: index))
                prevDate = healthRecord.date!
            }
        }
    }

    fileprivate func expandYearHeader(atIndex yearHeaderIndex: Int) -> Int {

        guard yearHeaderIndex < shownCells.count,
            let yearHeader = shownCells[yearHeaderIndex] as? YearHeaderCell,
            !yearHeader.isExpanded else {

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

    fileprivate func collapseYearHeader(atIndex yearHeaderIndex: Int) -> Int {

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

    fileprivate func expandDayHeader(atIndex dayHeaderIndex: Int) -> Int {

        guard   dayHeaderIndex < shownCells.count,
            let dayHeader = shownCells[dayHeaderIndex] as? DayHeaderCell,
            !dayHeader.isExpanded else {

                return 0
        }

        let targetDate = stateController.healthRecords[dayHeader.indexOfSource].date!

        for (i, healthRecord) in stateController.healthRecords.enumerated().dropLast(stateController.healthRecords.count - dayHeader.indexOfSource - 1).reversed() {

            guard !areDatesDifferent(prevDate: targetDate, currentDate: healthRecord.date!, forComponents: [.year, .month, .day]) else {

                break
            }

            // TODO: Should insert on top of the day section instead
            shownCells.insert(ContentCell(indexOfSource: i, indexOfDayHeader: dayHeaderIndex), at: dayHeaderIndex+1+dayHeader.entries)

            dayHeader.entries = dayHeader.entries + 1
        }

        dayHeader.isExpanded = true

        return dayHeader.entries
    }

    fileprivate func collapseDayHeaders(forYearHeader yearHeaderIndex: Int) -> Int {

        let yearHeader = shownCells[yearHeaderIndex] as! YearHeaderCell

        guard yearHeader.isExpanded else {

            return 0
        }

        let firstDayHeaderIndex = yearHeaderIndex + 1
        var rowsCollapsed = 0

        for dayHeaderIndex in firstDayHeaderIndex..<firstDayHeaderIndex+yearHeader.days! {

            rowsCollapsed += collapseDayHeader(atIndex: dayHeaderIndex)
        }

        return rowsCollapsed
    }

    fileprivate func collapseDayHeader(atIndex dayHeaderIndex: Int) -> Int {

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

    fileprivate func expandOrCollapseYearHeader(yearHeaderIndex: Int) -> Int {

        let yearHeader = shownCells[yearHeaderIndex] as! YearHeaderCell

        if !yearHeader.isExpanded {

            return expandYearHeader(atIndex: yearHeaderIndex)

        } else {

            return -collapseYearHeader(atIndex: yearHeaderIndex)
        }
    }

    fileprivate func expandOrCollapseDayHeader(dayHeaderIndex: Int) -> Int {

        let dayHeader = shownCells[dayHeaderIndex] as! DayHeaderCell

        if !dayHeader.isExpanded {

            return expandDayHeader(atIndex: dayHeaderIndex)

        } else {

            return -collapseDayHeader(atIndex: dayHeaderIndex)
        }
    }

    fileprivate func expandOrCollapseContent(contentIndex: Int) -> Bool {

        let content = shownCells[contentIndex] as! ContentCell

        if content.isExpanded == true {

            content.isExpanded = false

            return false

        } else {

            content.isExpanded = true

            return true
        }
    }

    // TODO: Write test case for this
    fileprivate func areDatesDifferent(prevDate: Date, currentDate: Date, forComponents targetComponents: [DateComponent]) -> Bool {

        let components: Set<Calendar.Component> = [.year, .month, .day, .hour]
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

    fileprivate func deleteContentRow(atIndex row: Int) -> [IndexPath] {

        let removedItem = shownCells.remove(at: row) as! ContentCell

        stateController.deleteARecord(atIndex: removedItem.indexOfSource!)
        adjustIndicesOfSource(endingAt: row, by: -1)
        var indexPathsToRemove = removeHeadersIfNeeded(startAtDayHeader: removedItem.indexOfDayHeader!)
        indexPathsToRemove.append(IndexPath(row: row, section: 0))

        let indexOfRowAfterDeletedRow = row + 1 - indexPathsToRemove.count
        adjustIndicesOfHeaders(startingAt: indexOfRowAfterDeletedRow, by: -indexPathsToRemove.count)

        return indexPathsToRemove
    }

    fileprivate func removeHeadersIfNeeded(startAtDayHeader indexOfDayHeader: Int) -> [IndexPath] {

        var indexPathsToRemove = [IndexPath]()

        let dayHeaderCell = shownCells[indexOfDayHeader] as! DayHeaderCell
        dayHeaderCell.entries = dayHeaderCell.entries - 1

        if dayHeaderCell.entries == 0 {

            let removedDayHeader = shownCells.remove(at: indexOfDayHeader) as! DayHeaderCell
            indexPathsToRemove.append(IndexPath(row: indexOfDayHeader, section: 0))
            
            let indexOfYearHeader = removedDayHeader.indexOfYearHeader!
            let yearHeaderCell = shownCells[indexOfYearHeader] as! YearHeaderCell
            yearHeaderCell.days = yearHeaderCell.days - 1
            
            if yearHeaderCell.days == 0 {
                
                shownCells.remove(at: indexOfYearHeader)
                indexPathsToRemove.append(IndexPath(row: indexOfYearHeader, section: 0))
            }
        }
        
        return indexPathsToRemove
    }
    
    fileprivate func adjustIndicesOfSource(endingAt endRow: Int, by amount: Int) {
        
        for i in 0..<endRow {
            
            let shownCell = shownCells[i] as! VisibleCell
            
            shownCell.indexOfSource = shownCell.indexOfSource + amount
        }
    }

    fileprivate func adjustIndicesOfHeaders(startingAt startRow: Int, by amount: Int) {

        var yearHeaderFound = false
        var dayHeaderFound = false

        for shownCell in shownCells.dropFirst(startRow) {

            if let contentCell = shownCell as? ContentCell {

                if yearHeaderFound || dayHeaderFound {

                    contentCell.indexOfDayHeader = contentCell.indexOfDayHeader + amount
                }

            } else if let dayHeaderCell = shownCell as? DayHeaderCell {

                if yearHeaderFound {

                    dayHeaderCell.indexOfYearHeader = dayHeaderCell.indexOfYearHeader + amount
                }

                dayHeaderFound = true

            } else if shownCell is YearHeaderCell {

                yearHeaderFound = true
            }
        }
    }
}

extension TableViewDataSource {

    func showNewCondition(newCondition: HealthCondition) {

        let latestYearHeader = 0
        let latestDayHeader = 1
        let latestContent = 2
        var cellsAdded = 0

        if shownCells.count == 0 {

            initShownCells()

        } else {

            let mostRecentDate = stateController.healthRecords[(shownCells[latestYearHeader] as! YearHeaderCell).indexOfSource].date!
            let indexOfSource = stateController.healthRecords.count - 1

            if areDatesDifferent(prevDate: mostRecentDate, currentDate: newCondition.date!, forComponents: [.year]) {

                shownCells.insert(YearHeaderCell(indexOfSource: indexOfSource), at: latestYearHeader)

                _ = expandYearHeader(atIndex: latestYearHeader)
                _ = expandDayHeader(atIndex: latestDayHeader)

                // 1 year header + 1 day header + 1 content cell
                cellsAdded = 3
                
            } else if areDatesDifferent(prevDate: mostRecentDate, currentDate: newCondition.date!, forComponents: [.year, .month, .day]) {

                let yearHeader = shownCells[latestYearHeader] as! YearHeaderCell
                yearHeader.indexOfSource = indexOfSource

                // num of day headers + 1 content cell
                cellsAdded = expandYearHeader(atIndex: latestYearHeader) + 1

                if cellsAdded <= 1 {

                    // year header was already expanded

                    yearHeader.days = yearHeader.days + 1
                    shownCells.insert(DayHeaderCell(indexOfSource: indexOfSource, indexOfYearHeader: latestYearHeader), at: latestDayHeader)
                    _ = expandDayHeader(atIndex: latestDayHeader)

                    // 1 day header + 1 content cell
                    cellsAdded = 2
                }

                _ = expandDayHeader(atIndex: latestDayHeader)

            } else {

                (shownCells[latestYearHeader] as! YearHeaderCell).indexOfSource = indexOfSource

                // num of day headers + 1 content cell
                cellsAdded = expandYearHeader(atIndex: latestYearHeader) + 1

                if cellsAdded > 1 {

                    // year header wasn't expanded yet

                    cellsAdded += expandDayHeader(atIndex: latestDayHeader)

                } else {

                    let dayHeader = shownCells[latestDayHeader] as! DayHeaderCell
                    dayHeader.indexOfSource = indexOfSource

                    let contentCellsAdded = expandDayHeader(atIndex: latestDayHeader)

                    // add num of content cells
                    cellsAdded += contentCellsAdded

                    if contentCellsAdded == 0 {

                        // day header was already expanded
                        
                        dayHeader.entries = dayHeader.entries + 1
                        shownCells.insert(ContentCell(indexOfSource: indexOfSource, indexOfDayHeader: latestDayHeader), at: latestContent)
                    }
                }
            }
        }
        
        _ = expandOrCollapseContent(contentIndex: latestContent)

        if cellsAdded > 0 {

            let indexOfNewContentCell = latestYearHeader + cellsAdded - 1

            adjustIndicesOfHeaders(startingAt: indexOfNewContentCell + 1, by: cellsAdded)
        }
    }
}

// Helper functions, not essential to the app

extension TableViewDataSource {

    fileprivate func printShownCells() {

        for i in 0..<shownCells.count {

            if let yearHeaderCell = shownCells[i] as? YearHeaderCell {

                print("Year: \(HealthCondition.generateStringFromDateInLocalTimezone(date: stateController.healthRecords[yearHeaderCell.indexOfSource!].date))")

            } else if let dayHeaderCell = shownCells[i] as? DayHeaderCell {

                print("Day: \(HealthCondition.generateStringFromDateInLocalTimezone(date: stateController.healthRecords[dayHeaderCell.indexOfSource!].date))")

            } else if let contentCell = shownCells[i] as? ContentCell {

                print("Content: \(HealthCondition.generateStringFromDateInLocalTimezone(date: stateController.healthRecords[contentCell.indexOfSource!].date))")
            }
        }
    }
}

