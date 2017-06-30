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
//        print("atSource: \(atSourceIndex), atIndex: \(atIndex)")
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

extension TableViewDataSource: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        print("shownCells count: \(shownCells.count)")
        return shownCells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        print("cellForRowAt: \(indexPath.row)")
        
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        print("did select row: \(indexPath.row)")
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

