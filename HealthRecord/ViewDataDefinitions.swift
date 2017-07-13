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
    var indexOfSource: Int!

    init(indexOfSource: Int) {

        self.isExpanded = false
        self.indexOfSource = indexOfSource
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
}

class DayHeaderCell: VisibleCell {

    var entries: Int!
    var indexOfYearHeader: Int!

    init(indexOfSource: Int, indexOfYearHeader: Int) {
        super.init(indexOfSource: indexOfSource)

        self.indexOfYearHeader = indexOfYearHeader
        self.entries = 0
    }
}

class ContentCell: VisibleCell {

    var indexOfDayHeader: Int!

    init(indexOfSource: Int, indexOfDayHeader: Int) {
        super.init(indexOfSource: indexOfSource)

        self.indexOfDayHeader = indexOfDayHeader
    }
}
