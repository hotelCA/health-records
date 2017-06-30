//
//  StateController.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/29/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import Foundation

class StateController {

    var healthRecords = [HealthCondition]()

    init() {

        loadHealthRecord()

        for i in 0..<healthRecords.count {

            print(healthRecords[i].date)
        }
    }

    func loadHealthRecord() {

        for i in 1..<80 {

            var index = i / 4

            healthRecords.append(HealthCondition(timeOfCondition: Date(timeIntervalSinceNow: TimeInterval(3*index*OneMonth + i)), condition: ConditionEnum.pain))
        }
    }

}
