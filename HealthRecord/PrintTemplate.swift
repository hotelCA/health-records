//
//  PrintTemplate.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 7/14/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import Foundation

class YearHeaderTemplate {

    let content: String
    let opening = "\n" +
                  "<tr class=\"year header\">" + "\n" +
                  "\t" + "<td colspan=\"2\">" + "\n"

    let closing = "\t" + "</td>" + "\n" +
                  "</tr>" + "\n"

    var header: String {

        return opening + "\t\t" + content + "\n" + closing
    }

    init(content: String) {

        self.content = content
    }
}

class DayHeaderTemplate {

    let content: String
    let opening = "<tr class=\"day header\">" + "\n" +
        "\t" + "<td colspan=\"2\">" + "\n"

    let closing = "\t" + "</td>" + "\n" +
                  "</tr>" + "\n"

    var header: String {

        return opening + "\t\t" + content + "\n" + closing
    }

    init(content: String) {

        self.content = content
    }
}

class ConditionDescriptionTemplate {

    let content: (key: String, value: String)

    let opening = "<tr class=\"condition\">" + "\n"
    let closing = "</tr>" + "\n"
    let openingSection = "\t" + "<td>" + "\n"
    let closingSection = "\t" + "</td>" + "\n"

    var description: String {

        return opening + openingSection + "\t\t" + content.key + "\n" + closingSection + openingSection + "\t\t" + content.value + "\n" + closingSection + closing
    }

    init(content: (String, String)) {

        self.content = content
    }
}
