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

    init(timeOfCondition: Date) {

        self.date = timeOfCondition
    }
}

class HealthDescription: HealthCondition {

    var condition: ConditionEnum!
    var degree: Int?
    var location: Int?
    var detailedDescription: String?

    init(timeOfDescription: Date, condition: ConditionEnum) {
        super.init(timeOfCondition: timeOfDescription)

        self.condition = condition
    }

}

class HealthImage: HealthCondition {

    var image: UIImage!

    init(timeOfImage: Date, image: UIImage) {
        super.init(timeOfCondition: timeOfImage)

        self.image = image
    }
}

class VisibleCell {

    var isExpanded: Bool
    var indexOfSource: Int!

    init() {

        self.isExpanded = false
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

    init(indexOfSource: Int) {
        super.init()

        self.indexOfSource = indexOfSource
        self.days = 0
    }
}

class DayHeaderCell: VisibleCell {

    var entries: Int!

    init(indexOfSource: Int) {
        super.init()

        self.indexOfSource = indexOfSource
        self.entries = 0
    }
}

class ContentCell: VisibleCell {

    var healthCondition: HealthCondition!

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

enum ConditionEnum: Int {

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


