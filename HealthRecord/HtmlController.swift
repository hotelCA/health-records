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

    var htmlContent: String!

    override init() {
        super.init()
    }

    func renderHealthRecord(_ shownCells: [VisibleCell], _ healthRecords: [HealthCondition]) -> String? {

        guard shownCells.count > 0 else {

            return nil
        }

        do {

            htmlContent = try String(contentsOfFile: pathToHTMLTemplate!)
            let content = generateContent(shownCells, healthRecords)

            htmlContent = htmlContent.replacingOccurrences(of: "#CONTENT#", with: content)

            return htmlContent
            
        } catch {

            print("Unable to open and use HTML template file.")
            return nil
        }
    }

    private func generateContent(_ shownCells: [VisibleCell], _ healthRecords: [HealthCondition]) -> String {

        var content = String()

        for shownCell in shownCells {

            let healthCondition = healthRecords[shownCell.indexOfSource]

            if shownCell is YearHeaderCell {

                let year = String(getDateComponents(for: healthCondition.date, components: [.year])[0])

                content += YearHeaderTemplate(content: year).header

            } else if shownCell is DayHeaderCell {

                let dateComponents = getDateComponents(for: healthCondition.date, components: [.month, .day])

                let monthAndDay = "\(dateComponents[0])-\(dateComponents[1])"

                content += DayHeaderTemplate(content: monthAndDay).header

            } else if shownCell is ContentCell {

                if let healthDescription = healthCondition as? HealthDescription {

                    content += ConditionDescriptionTemplate(content: ("Condition", healthDescription.condition.description)).description

                } else if let healthImage = healthCondition as? HealthImage {

                    let fileNameUrl = documentDirectory.appendingPathComponent(HealthImage.generateFileNameFrom(date: healthImage.date))

                    let imageFileName = fileNameUrl.absoluteString
                    print(imageFileName)

                    content += ConditionImageTemplate(content: ("Image", imageFileName)).image
                }
            }
        }

        return content
    }

    fileprivate func getDateComponents(for date: Date, components: [DateComponent]) -> [Int] {

        var returnDateComponents = [Int]()
        let componentFlags: Set<Calendar.Component> = [.year, .month, .day]
        let dateComponents = Calendar.current.dateComponents(componentFlags, from: date)

        if components.contains(.year) {

            returnDateComponents.append(dateComponents.year!)
        }

        if components.contains(.month) {

            returnDateComponents.append(dateComponents.month!)
        }

        if components.contains(.day) {

            returnDateComponents.append(dateComponents.day!)
        }

        return returnDateComponents
    }
}
