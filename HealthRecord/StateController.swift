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
    var loaded: Bool!

    init() {

        loaded = false

        let environment = ProcessInfo.processInfo.environment

        if environment["TEST"] == "true" {

            loadHealthRecord()
            print("Launch for UI TESTING")

        } else {

            loadHealthRecord()
            print("Regular launch")
        }

        for i in 0..<healthRecords.count {

            print(healthRecords[i].date!)
        }
    }

    func loadHealthRecord() {

        if !loaded {
            
            loaded = true

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
}
