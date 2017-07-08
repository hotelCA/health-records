//
//  StateController.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/29/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

class StateController {

    var healthRecords = [HealthCondition]()

    init() {

        loadHealthRecord()

        for i in 0..<healthRecords.count {

            print(healthRecords[i].date!)
        }
    }

    func loadHealthRecord() {

        for i in 12..<80 {

            let index = i / 4
            var newCondition: HealthCondition!

            if i % 2 == 0 {

                newCondition = HealthDescription(timeOfDescription: Date(timeIntervalSince1970: TimeInterval(3*index*OneMonth + i)), condition: ConditionEnum.pain)

            } else {

                let newImage = UIImage(named: "20160704_145508.jpg")
                newCondition = HealthImage(timeOfImage: Date(timeIntervalSince1970: TimeInterval(3*index*OneMonth + i)), image: newImage!)
            }

            healthRecords.append(newCondition)
        }
    }

}
