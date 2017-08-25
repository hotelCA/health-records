//
//  TableViewDataSource.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/29/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

class TableViewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate, CustomTableViewCellProtocol {

    var stateController: StateController!

    var shownCells = [Any]()

    var tableView: UITableView!

    init(stateController: StateController) {
        super.init()

        self.stateController = stateController
        initShownCells()
        Utilities.printShownCells(shownCells: shownCells as! [VisibleCell], healthRecords: stateController.healthRecords)
    }

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return shownCells.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        var height = CGFloat(40)

        if let contentCell = shownCells[indexPath.row] as? ContentCell {

            if stateController.healthRecords[contentCell.indexOfSource!] is HealthImage {

                if contentCell.isExpanded {

                    height = 220

                } else {

                    height = 60
                }

            } else if stateController.healthRecords[contentCell.indexOfSource!] is HealthDescription {

                if contentCell.isExpanded {

                    height = 120

                } else {

                    height = 60
                }
            }
        }

        return height
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let yearHeaderCell = shownCells[indexPath.row] as? YearHeaderCell {

            let yearCell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! HeaderViewCell

            yearCell.headerLabel?.text = "Year: \(HealthCondition.generateStringFromDateInLocalTimezone(date: stateController.healthRecords[yearHeaderCell.indexOfSource!].date))"

            if stateController.mode == .printing {

                yearCell.loadPrintMode(row: indexPath.row, delegate: self, selected: yearHeaderCell.isSelected)
            }

            return yearCell

        } else if let dayHeaderCell = shownCells[indexPath.row] as? DayHeaderCell {

            let dayCell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! HeaderViewCell

            dayCell.headerLabel?.text = "Day: \(HealthCondition.generateStringFromDateInLocalTimezone(date: stateController.healthRecords[dayHeaderCell.indexOfSource!].date))"

            if stateController.mode == .printing {

                dayCell.loadPrintMode(row: indexPath.row, delegate: self, selected: dayHeaderCell.isSelected)
            }

            return dayCell

        } else if let contentCell = shownCells[indexPath.row] as? ContentCell {

            let healthCondition = stateController.healthRecords[contentCell.indexOfSource!]

            if let healthDescription = healthCondition as? HealthDescription {

                let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as! DescriptionTableViewCell

                descriptionCell.MedicalDescriptionLabel?.text = "Day: \(healthDescription.condition!)"

                if stateController.mode == .printing {

                    descriptionCell.loadPrintMode(row: indexPath.row, delegate: self, selected: contentCell.isSelected)
                }

                contentCell.isExpanded ? descriptionCell.showExtraContent() : descriptionCell.hideExtraContent()

                return descriptionCell

            } else if let healthImage = healthCondition as? HealthImage {

                let imageCell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageTableViewCell

                imageCell.medicalImage?.image = healthImage.image
                
                if stateController.mode == .printing {

                    imageCell.loadPrintMode(row: indexPath.row, delegate: self, selected: contentCell.isSelected)
                }

                contentCell.isExpanded ? imageCell.showExtraContent() : imageCell.hideExtraContent()

                return imageCell
            }
        }

        // It should never get here
        return UITableViewCell()
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

            let lastModifiedRow = indexPath.row + 1 + abs(rowsToAddOrRemove)

            for i in indexPath.row+1..<lastModifiedRow {

                indexPaths.append(IndexPath(row: i, section: 0))
            }

            if stateController.mode == .printing {

                adjustButtonTagsFrom(row: lastModifiedRow, by: rowsToAddOrRemove)
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
            
            if !content.isExpanded && stateController.mode == .normal {

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

// Helper functions
extension TableViewDataSource {

    fileprivate func initShownCells() {

        let indexOfLatestYearHeader = 0
        let indexOfLatestDayHeader = 1

        showYearHeaders()
        _ = expandYearHeader(atIndex: indexOfLatestYearHeader, visibleCells: &shownCells)
        _ = expandDayHeader(atIndex: indexOfLatestDayHeader, visibleCells: &shownCells)
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

    fileprivate func expandYearHeader(atIndex yearHeaderIndex: Int, visibleCells: inout [Any]) -> Int {

        guard yearHeaderIndex < visibleCells.count,
            let yearHeader = visibleCells[yearHeaderIndex] as? YearHeaderCell,
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

                let index = yearHeaderIndex + 1 + yearHeader.days

                visibleCells.insert(DayHeaderCell(indexOfSource: i, indexOfYearHeader: yearHeaderIndex), at: index)

                (visibleCells[index] as! DayHeaderCell).isSelected = (visibleCells[yearHeaderIndex] as! YearHeaderCell).isSelected

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

    fileprivate func expandDayHeader(atIndex dayHeaderIndex: Int, visibleCells: inout [Any]) -> Int {

        guard   dayHeaderIndex < visibleCells.count,
            let dayHeader = visibleCells[dayHeaderIndex] as? DayHeaderCell,
            !dayHeader.isExpanded else {

                return 0
        }

        let targetDate = stateController.healthRecords[dayHeader.indexOfSource].date!

        for (i, healthRecord) in stateController.healthRecords.enumerated().dropLast(stateController.healthRecords.count - dayHeader.indexOfSource - 1).reversed() {

            guard !areDatesDifferent(prevDate: targetDate, currentDate: healthRecord.date!, forComponents: [.year, .month, .day]) else {

                break
            }

            let index = dayHeaderIndex + 1 + dayHeader.entries

            visibleCells.insert(ContentCell(indexOfSource: i, indexOfDayHeader: dayHeaderIndex), at: index)

            (visibleCells[index] as! ContentCell).isSelected = (visibleCells[dayHeaderIndex] as! DayHeaderCell).isSelected

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

            return expandYearHeader(atIndex: yearHeaderIndex, visibleCells: &shownCells)

        } else {

            return -collapseYearHeader(atIndex: yearHeaderIndex)
        }
    }

    fileprivate func expandOrCollapseDayHeader(dayHeaderIndex: Int) -> Int {

        let dayHeader = shownCells[dayHeaderIndex] as! DayHeaderCell

        if !dayHeader.isExpanded {

            return expandDayHeader(atIndex: dayHeaderIndex, visibleCells: &shownCells)

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

    fileprivate func adjustButtonTagsFrom(row: Int, by cellCount: Int) {

        var row = row

        print("row \(row), by \(cellCount)")

        while let cell = tableView.cellForRow(at: IndexPath(row: row - max(cellCount, 0), section: 0)) as? CustomTableViewCell {

            print("row \(row), by \(cellCount)")
            cell.setCheckButtonTag(tag: row + min(cellCount, 0))
            row += 1
        }
    }
}

// Functions that can be called from outside
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

                _ = expandYearHeader(atIndex: latestYearHeader, visibleCells: &shownCells)
                _ = expandDayHeader(atIndex: latestDayHeader, visibleCells: &shownCells)

                // 1 year header + 1 day header + 1 content cell
                cellsAdded = 3
                
            } else if areDatesDifferent(prevDate: mostRecentDate, currentDate: newCondition.date!, forComponents: [.year, .month, .day]) {

                let yearHeader = shownCells[latestYearHeader] as! YearHeaderCell
                yearHeader.indexOfSource = indexOfSource

                // num of day headers + 1 content cell
                cellsAdded = expandYearHeader(atIndex: latestYearHeader, visibleCells: &shownCells) + 1

                if cellsAdded <= 1 {

                    // year header was already expanded

                    yearHeader.days = yearHeader.days + 1
                    shownCells.insert(DayHeaderCell(indexOfSource: indexOfSource, indexOfYearHeader: latestYearHeader), at: latestDayHeader)
                    _ = expandDayHeader(atIndex: latestDayHeader, visibleCells: &shownCells)

                    // 1 day header + 1 content cell
                    cellsAdded = 2
                }

                _ = expandDayHeader(atIndex: latestDayHeader, visibleCells: &shownCells)

            } else {

                (shownCells[latestYearHeader] as! YearHeaderCell).indexOfSource = indexOfSource

                // num of day headers + 1 content cell
                cellsAdded = expandYearHeader(atIndex: latestYearHeader, visibleCells: &shownCells) + 1

                if cellsAdded > 1 {

                    // year header wasn't expanded yet

                    cellsAdded += expandDayHeader(atIndex: latestDayHeader, visibleCells: &shownCells)

                } else {

                    let dayHeader = shownCells[latestDayHeader] as! DayHeaderCell
                    dayHeader.indexOfSource = indexOfSource

                    let contentCellsAdded = expandDayHeader(atIndex: latestDayHeader, visibleCells: &shownCells)

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


// Functions used in print mode
extension TableViewDataSource {

    // This is CustomTableViewCellProtocol
    func checkButtonPressed(selected: Bool, tag: Int) {

        (shownCells[tag] as! VisibleCell).isSelected = selected

        if shownCells[tag] is YearHeaderCell {

            changeChildCheckButtonStates(atIndex: tag + 1, for: [.dayHeader, .content], selected)

        } else if shownCells[tag] is DayHeaderCell {

            changeChildCheckButtonStates(atIndex: tag + 1, for: [.content], selected)

        }

        correctParentCheckButtonStates()

        print("Button \(tag), Pressed: \(selected)")
    }

    func changeChildCheckButtonStates(atIndex: Int, for cellTypes: [VisibleCellEnum],_ isSelected: Bool) {

        for (i, shownCell) in shownCells.enumerated().dropFirst(atIndex){

            if (shownCell is YearHeaderCell) || ((shownCell is DayHeaderCell) && !cellTypes.contains(.dayHeader)){

                break
            }

            (shownCell as! VisibleCell).isSelected = isSelected

            // Cells might not be in the view, so the function might return nil
            if let customCell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? CustomTableViewCell {

                customCell.setSelected(selected: isSelected)
            }
        }
    }

    func correctParentCheckButtonStates() {

        for i in (0..<shownCells.count).reversed() {

            let parentCell = shownCells[i] as! VisibleCell
            let previousSelectedState = parentCell.isSelected
            var noChildCellShown = true

            if shownCells[i] is YearHeaderCell {

                parentCell.isSelected = true

                for j in (i+1)..<shownCells.count {

                    guard !(shownCells[j] is YearHeaderCell) else {

                        break
                    }

                    noChildCellShown = false

                    if (shownCells[j] as! VisibleCell).isSelected == false {

                        parentCell.isSelected = false
                        break
                    }
                }

                if noChildCellShown {

                    parentCell.isSelected = previousSelectedState

                } else {

                    if let customCell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? CustomTableViewCell {

                        customCell.setSelected(selected: parentCell.isSelected)
                    }
                }

            } else if shownCells[i] is DayHeaderCell {

                parentCell.isSelected = true

                for j in (i+1)..<shownCells.count {

                    guard !(shownCells[j] is YearHeaderCell),
                          !(shownCells[j] is DayHeaderCell) else {

                        break
                    }

                    noChildCellShown = false

                    if (shownCells[j] as! VisibleCell).isSelected == false {

                        parentCell.isSelected = false
                        break
                    }
                }

                if noChildCellShown {

                    parentCell.isSelected = previousSelectedState

                } else {

                    if let customCell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? CustomTableViewCell {

                        customCell.setSelected(selected: parentCell.isSelected)
                    }
                }
            }
        }
    }

    func getDataForPrinting() -> [VisibleCell] {

        var printCells = [Any]()

        let selectedCells = shownCells.filter { ($0 as! VisibleCell).isSelected }

        for cell in selectedCells as! [VisibleCell] {

            if let yearHeader = cell as? YearHeaderCell {

                printCells.append(YearHeaderCell(yearHeader: yearHeader) as Any)

            } else if let dayHeader = cell as? DayHeaderCell {

                let yearHeader = shownCells[dayHeader.indexOfYearHeader] as! YearHeaderCell

                if !yearHeader.isSelected {

                    printCells.append(YearHeaderCell(yearHeader: yearHeader) as Any)
                    yearHeader.isSelected = true
                }

                printCells.append(DayHeaderCell(dayHeader: dayHeader) as Any)

            } else if let content = cell as? ContentCell {

                let dayHeader = shownCells[content.indexOfDayHeader] as! DayHeaderCell
                let yearHeader = shownCells[dayHeader.indexOfYearHeader] as! YearHeaderCell

                if !yearHeader.isSelected {

                    printCells.append(YearHeaderCell(yearHeader: yearHeader) as Any)
                    yearHeader.isSelected = true
                }

                if !dayHeader.isSelected {

                    printCells.append(DayHeaderCell(dayHeader: dayHeader) as Any)
                    dayHeader.isSelected = true
                }

                printCells.append(ContentCell(contentCell: content) as Any)
            }
        }

        // Reset back to unselected state
        shownCells = shownCells.map({ (visibleCell: Any) -> Any in

            (visibleCell as! VisibleCell).isSelected = false
            return visibleCell
        })

        return expandSelectedHeaders(printCells: &printCells) as! [VisibleCell]
    }

    func expandSelectedHeaders(printCells: inout [Any]) -> [Any] {

        var i = 0

        while i < printCells.count {

            if let yearHeader = printCells[i] as? YearHeaderCell {

                if yearHeader.isSelected {

                    _ = expandYearHeader(atIndex: i, visibleCells: &printCells)
                }

            } else if let dayHeader = printCells[i] as? DayHeaderCell {

                if dayHeader.isSelected {

                    _ = expandDayHeader(atIndex: i, visibleCells: &printCells)
                }
            }

            i += 1
        }

        return printCells
    }
}
