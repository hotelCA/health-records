//
//  StateController.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/29/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit
import CoreData

class StateController {

    var healthRecords = [HealthCondition]()
    var loaded: Bool!

    init() {

        self.loaded = false

        let environment = ProcessInfo.processInfo.environment

        if environment["TEST"] == "true" {

            self.loadTestHealthRecord()
            print("Launch for UI TESTING")

        } else {

            loadHealthRecords()
            print("Regular launch")
        }

        for i in 0..<healthRecords.count {

            print(healthRecords[i].date!)
        }
    }

    func saveARecord(healthCondition: HealthCondition) {

        healthRecords.append(healthCondition)

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newHealthCondition = NSEntityDescription.insertNewObject(forEntityName: "HealthRecord", into: context)

        newHealthCondition.setValue(healthCondition.date, forKey: "date")

        if let healthDescription = healthCondition as? HealthDescription {

            newHealthCondition.setValue(healthDescription.condition.rawValue, forKey: "condition")

        } else if let healthImage = healthCondition as? HealthImage {

            newHealthCondition.setValue(UIImagePNGRepresentation(healthImage.image), forKey: "image")

            // Use this value to disqualify this as a HealthDescription when fetching request
            newHealthCondition.setValue(-1, forKey: "condition")
        }

        do {

            try context.save()

            print("saved")
            
        } catch {

            print("error during saving core data")
        }
    }

    func deleteARecord(atIndex index: Int) {

        let removedRecord = healthRecords.remove(at: index)

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "HealthRecord")
        request.returnsObjectsAsFaults = false

        request.predicate = NSPredicate(format: "date = %@", argumentArray: [removedRecord.date!])

        do {

            let results = try context.fetch(request)

            if results.count > 0 {

                print("found \(results.count) items")

                context.delete(results[0] as! NSManagedObject)

                do {

                    try context.save()

                } catch {

                    print("Deleting a record failed!")
                }

            } else {

                print("Didn't find any results to delete")
            }

        } catch {

            print("Couldn't fetch results from deleteARecord")
        }
    }

    func loadHealthRecords() {

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "HealthRecord")
        request.returnsObjectsAsFaults = false

        do {

            let results = try context.fetch(request)

            if results.count > 0 {

                for result in results as! [NSManagedObject] {

                    if let condition = ConditionEnum(rawValue: result.value(forKey: "condition") as! ConditionEnum.RawValue) {

                        print("loaded description")

                        let healthDescription = HealthDescription(timeOfDescription: result.value(forKey: "date") as! Date, condition: condition)

                        healthRecords.append(healthDescription)

                    } else if let imageData = result.value(forKey: "image") as? Data {

                        print("loaded image")

                        let healthImage = HealthImage(timeOfImage: result.value(forKey: "date") as! Date, image: UIImage(data: imageData)!)

                        healthRecords.append(healthImage)
                    }
                }

            } else {

                print("there are no saved health records")
            }

        } catch {

            print("Couldn't fetch results")
        }
    }

    func loadTestHealthRecord() {

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
