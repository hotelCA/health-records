//
//  File.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/18/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

class HealthCondition {

    var date: Date?
    var condition: ConditionEnum?
//    var degree: Int?
//    var location: Int?
//    var description: String?
//    var image: UIImage?
//
//    init(condition: Int?, degree: Int?, location: Int?, description: String?) {
//
//        self.condition = condition
//        self.degree = degree
//        self.location = location
//        self.description = description
//    }

    init(timeOfCondition: Date, condition: ConditionEnum) {

        self.date = timeOfCondition
        self.condition = condition
    }
}

class VisibleCell {

    var isExpanded: Bool
    var indexOfSource: Int?

    init() {

        self.isExpanded = false
    }
}

class YearHeaderCell: VisibleCell {

    var days: Int?

    init(indexOfSource: Int) {
        super.init()

        self.indexOfSource = indexOfSource
        self.days = 0
    }
}

class DayHeaderCell: VisibleCell {

    var entries: Int?

    init(indexOfSource: Int) {
        super.init()

        self.indexOfSource = indexOfSource
        self.entries = 0
    }
}

class ContentCell: VisibleCell {

    var healthCondition: HealthCondition?

    init(healthCondition: HealthCondition, indexOfSource: Int) {
        super.init()

        self.indexOfSource = indexOfSource
        self.healthCondition = healthCondition
    }
}

enum DateComponent {

    case day
    case month
    case year
}

class HealthImage {

    var image: UIImage?

    init(image: UIImage?) {

        self.image = image
    }
}

enum ConditionEnum {

    case pain
    case itch
    case tingling
    case numb
    case ache
}

enum DegreeEnum {

    case mild
    case medium
    case severe
}

enum LocationEnum {

    case head
    case body
    case arm
    case leg
    case foot
}


