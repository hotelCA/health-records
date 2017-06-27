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
//    var condition: Int?
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

    init(timeOfCondition: Date) {

        self.date = timeOfCondition
    }
}

class HeaderCell {

    var isExpandable: Bool
    var isExpanded: Bool
    var isShown: Bool

    init() {

        self.isExpandable = true
        self.isExpanded = false
        self.isShown = false
    }
}

class YearHeaderCell: HeaderCell {

    var year: Int?

    init(year: Int) {
        super.init()

        self.year = year
        self.isShown = true
    }
}

class DayHeaderCell: HeaderCell {

    var day: Int?

    init(day: Int) {
        super.init()

        self.day = day
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

    case Pain
    case Itch
    case Tingling
    case Numb
    case Ache
}

enum DegreeEnum {

    case Mild
    case Medium
    case Severe
}

enum LocationEnum {

    case Head
    case Body
    case Arm
    case Leg
    case Foot
}

class ExpandableCell {

    var IsExpandable: Bool?
    var IsExpanded: Bool?
    var IsVisible: Bool?
}

