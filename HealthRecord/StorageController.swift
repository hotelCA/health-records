//
//  StorageController.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 7/12/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//
import UIKit
import CoreData

var imageFileName: String!
var documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

class StorageController {

    let imageFlag: Int = -1

    func add(_ healthCondition: HealthCondition) {

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let newHealthCondition = NSEntityDescription.insertNewObject(forEntityName: "HealthRecord", into: context)

        set(managedObject: newHealthCondition, healthCondition: healthCondition)

        do {

            try context.save()

            print("saved")

        } catch {
            
            print("error during saving core data")
        }

    }

    func update(_ healthCondition: HealthCondition) {

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "HealthRecord")
        request.returnsObjectsAsFaults = false

        request.predicate = NSPredicate(format: "date = %@", argumentArray: [healthCondition.date!])

        do {

            var results = try context.fetch(request) as! [NSManagedObject]

            if results.count == 1 {

                print("Record updated.")

                set(managedObject: results[0], healthCondition: healthCondition)

                do {

                    try context.save()

                    // TODO: remove file

                } catch {

                    print("Updating a record failed!")
                }

            } else if results.count > 1 {

                print("Found more than one record matching target.")

            } else {

                print("Didn't find any matching record.")
            }

        } catch {

            print("Couldn't fetch results from updating a record.")
        }
    }

    private func set(managedObject: NSManagedObject, healthCondition: HealthCondition) {

        managedObject.setValue(healthCondition.date, forKey: "date")

        if let healthDescription = healthCondition as? HealthDescription {

            managedObject.setValue(healthDescription.condition.rawValue, forKey: "condition")

        } else if let healthImage = healthCondition as? HealthImage {

            let fullPathToFile = getFullPathToFile(name: HealthImage.generateFileNameFrom(date: healthImage.date))

            managedObject.setValue(HealthImage.generateFileNameFrom(date: healthImage.date), forKey: "imagePath")

            // Use this value to disqualify this as a HealthDescription when fetching request
            managedObject.setValue(imageFlag, forKey: "condition")

            saveImageToFile(fileName: fullPathToFile, image: healthImage.image)
        }
    }

    func remove(_ healthCondition: HealthCondition) {

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "HealthRecord")
        request.returnsObjectsAsFaults = false

        request.predicate = NSPredicate(format: "date = %@", argumentArray: [healthCondition.date!])

        do {

            let results = try context.fetch(request)

            if results.count == 1 {

                print("Record deleted.")

                context.delete(results[0] as! NSManagedObject)

                do {

                    try context.save()

                    // TODO: remove file

                } catch {

                    print("Deleting a record failed!")
                }

            } else if results.count > 1 {

                print("Found more than one record matching target.")

            } else {

                print("Didn't find any matching record.")
            }
            
        } catch {
            
            print("Couldn't fetch results from deleteARecord.")
        }
    }

    func fetchHealthRecords() -> [HealthCondition] {

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "HealthRecord")
        request.returnsObjectsAsFaults = false

        do {

            let results = try context.fetch(request)

            if results.count > 0 {

                return loadHealthRecords(fetchedResults: results as! [NSManagedObject])

            } else {
                
                print("there are no saved health records")
            }

        } catch {
            
            print("Couldn't fetch results")
        }

        return [HealthCondition]()
    }

    func deleteAllData() {

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "HealthRecord")
        request.returnsObjectsAsFaults = false

        do {

            let results = try context.fetch(request)

            for managedObject in results as! [NSManagedObject] {

                context.delete(managedObject)
            }

            do {

                try context.save()

            } catch {

                print("Deleting all records failed!")
            }

        } catch let error as NSError {

            print("Detele all data error : \(error) \(error.userInfo)")
        }
    }

    private func loadHealthRecords(fetchedResults: [NSManagedObject]) -> [HealthCondition] {

        var healthRecords = [HealthCondition]()

        for result in fetchedResults {

            if let condition = ConditionEnum(rawValue: result.value(forKey: "condition") as! ConditionEnum.RawValue) {

                print("loaded description")

                let healthDescription = HealthDescription(timeOfDescription: result.value(forKey: "date") as! Date, condition: condition)

                healthRecords.append(healthDescription)

            } else if let imageData = result.value(forKey: "imagePath") as? String {

                print("loaded image")

                let healthImage = HealthImage(timeOfImage: result.value(forKey: "date") as! Date, image: generateImageFrom(fileName: imageData)!)

                healthRecords.append(healthImage)
            }
        }

        return healthRecords
    }

    private func getFullPathToFile(name: String) -> String {

        return documentDirectory.appendingPathComponent(name).path
    }

    private func saveImageToFile(fileName: String, image: UIImage) {

        let imageData = UIImageJPEGRepresentation(image, 0.5)

        do {

            try imageData!.write(to: URL(fileURLWithPath: fileName))

        } catch {

            print("Couldn't write image data to file")
        }
    }

    private func generateImageFrom(fileName: String) -> UIImage? {

        let newFileName = documentDirectory.appendingPathComponent(fileName)

        let image = UIImage(contentsOfFile: newFileName.path)

        return image
    }
}
