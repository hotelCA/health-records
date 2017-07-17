//
//  HtmlGenerator.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 7/14/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import Foundation
import UIKit

class HtmlController: NSObject {

    let pathToHTMLTemplate = Bundle.main.path(forResource: "PrintTemplate", ofType: "html")

    let htmlImage = "20160704_145508.jpg"
    var htmlContent: String!

    override init() {
        super.init()
    }

    func renderHealthRecord(healthRecords: [HealthCondition]) -> String? {

//        guard healthRecords.count > 0 else {
//
//            return nil
//        }

        do {
            // Load the invoice HTML template code into a String variable.
            let htmlContent = try String(contentsOfFile: pathToHTMLTemplate!)
            let content = generateContent()

            self.htmlContent = htmlContent.replacingOccurrences(of: "#CONTENT#", with: content)

            return self.htmlContent
            
        } catch {

            print("Unable to open and use HTML template file.")
            return nil
        }
    }

    private func generateContent() -> String {

        let yearHeaderTemplate = YearHeaderTemplate(content: "2022").header
        let dayHeaderTemplate = DayHeaderTemplate(content: "22").header
        let conditionTemplate = ConditionDescriptionTemplate(content: ("Condition", "Numbness")).description

        return yearHeaderTemplate + dayHeaderTemplate + conditionTemplate
    }
}
