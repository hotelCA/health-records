//
//  ModelDataDefinitions.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 7/12/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import Foundation
import UIKit

class HealthCondition {

    var date: Date!

    init(timeOfCondition: Date) {

        self.date = timeOfCondition
    }

    class func generateStringFromDateInLocalTimezone(date: Date) -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        return dateFormatter.string(from: date)
    }

    class func generateStringFromDateInUTC(date: Date) -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as! TimeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        return dateFormatter.string(from: date)
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

    class func generateFileNameFrom(date: Date) -> String {

        var localPath = HealthCondition.generateStringFromDateInUTC(date: date)

        localPath = localPath.replacingOccurrences(of: "[ +:-]", with: "", options: String.CompareOptions.regularExpression, range: nil)

        return localPath
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
