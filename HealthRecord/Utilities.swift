//
//  Utilities.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 7/27/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import Foundation

class Utilities {

    static func printShownCells(shownCells: [VisibleCell], healthRecords: [HealthCondition]) {

        for i in 0..<shownCells.count {

            if let yearHeaderCell = shownCells[i] as? YearHeaderCell {

                print("Year: \(HealthCondition.generateStringFromDateInLocalTimezone(date: healthRecords[yearHeaderCell.indexOfSource!].date))")

            } else if let dayHeaderCell = shownCells[i] as? DayHeaderCell {

                print("Day: \(HealthCondition.generateStringFromDateInLocalTimezone(date: healthRecords[dayHeaderCell.indexOfSource!].date))")

            } else if let contentCell = shownCells[i] as? ContentCell {

                print("Content: \(HealthCondition.generateStringFromDateInLocalTimezone(date: healthRecords[contentCell.indexOfSource!].date))")
            }
        }
    }
}
