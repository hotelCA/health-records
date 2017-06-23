//
//  File.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/18/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

class HealthCondition {

    var condition: Int?
    var degree: Int?
    var location: Int?
    var description: String?
    var image: UIImage?

    init(condition: Int?, degree: Int?, location: Int?, description: String?) {

        self.condition = condition
        self.degree = degree
        self.location = location
        self.description = description
    }
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


