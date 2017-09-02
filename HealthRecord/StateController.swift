//
//  StateController.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/29/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

class StateController {

    var mode: ModeEnum
    let storageController: StorageController
    var healthRecords = [HealthCondition]()
    var testDataLoaded: Bool!

    init(storageController: StorageController) {

        mode = .normal

        self.storageController = storageController

        self.testDataLoaded = false

        let environment = ProcessInfo.processInfo.environment

        if environment["TEST"] == "true" {

            self.loadTestHealthRecord()

        } else {

            healthRecords = storageController.fetchHealthRecords()
//            storageController.deleteAllData()
        }

        for i in 0..<healthRecords.count {

            print(healthRecords[i].date!)
        }
    }

    func saveARecord(healthCondition: HealthCondition) {

        healthRecords.append(healthCondition)
        storageController.add(healthCondition)
    }

    func updateARecord(healthCondition: HealthCondition, atIndex index: Int) {

        healthRecords[index] = healthCondition
        storageController.update(healthCondition)
    }

    func deleteARecord(atIndex index: Int) {

        let removedRecord = healthRecords.remove(at: index)
        storageController.remove(removedRecord)
    }

    func loadTestHealthRecord() {

        if !testDataLoaded {

            testDataLoaded = true

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
