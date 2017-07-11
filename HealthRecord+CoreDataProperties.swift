//
//  HealthRecord+CoreDataProperties.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 7/10/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import Foundation
import CoreData


extension HealthRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HealthRecord> {
        return NSFetchRequest<HealthRecord>(entityName: "HealthRecord")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var condition: Int16
    @NSManaged public var image: NSData?

}
