//
//  File.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/18/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit


class VisibleCell {

    var isExpanded: Bool
    var isSelected: Bool
    var indexOfSource: Int

    init(indexOfSource: Int) {

        self.isExpanded = false
        self.isSelected = false
        self.indexOfSource = indexOfSource
    }

    init(visibleCell: VisibleCell) {

        print("VisibleCell copy constructor")
        self.isExpanded = visibleCell.isExpanded
        self.isSelected = visibleCell.isSelected
        self.indexOfSource = visibleCell.indexOfSource
    }

    func showExtraContent() {

        // Override this
    }

    func hideExtraContent() {

        // Override this
    }
}

class YearHeaderCell: VisibleCell {

    var days: Int!

    override init(indexOfSource: Int) {
        super.init(indexOfSource: indexOfSource)

        self.days = 0
    }

    init(yearHeader: YearHeaderCell) {
        super.init(visibleCell: yearHeader)

        print("YearHeaderCell copy constructor")
        self.days = yearHeader.days
    }
}

class DayHeaderCell: VisibleCell {

    var entries: Int!
    var indexOfYearHeader: Int!

    init(indexOfSource: Int, indexOfYearHeader: Int) {
        super.init(indexOfSource: indexOfSource)

        self.indexOfYearHeader = indexOfYearHeader
        self.entries = 0
    }

    init(dayHeader: DayHeaderCell) {
        super.init(visibleCell: dayHeader)

        self.indexOfYearHeader = dayHeader.indexOfYearHeader
        self.entries = dayHeader.entries
    }
}

class ContentCell: VisibleCell {

    var indexOfDayHeader: Int!

    init(indexOfSource: Int, indexOfDayHeader: Int) {
        super.init(indexOfSource: indexOfSource)

        self.indexOfDayHeader = indexOfDayHeader
    }

    init(contentCell: ContentCell) {
        super.init(visibleCell: contentCell)

        self.indexOfDayHeader = contentCell.indexOfDayHeader
    }
}

enum VisibleCellEnum {

    case yearHeader
    case dayHeader
    case content
}
