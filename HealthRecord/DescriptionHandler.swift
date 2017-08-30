//
//  ConditionHandler.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/30/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import Foundation

class DescriptionHandler {

    var viewController: TableViewController!

    init(viewController: TableViewController) {

        self.viewController = viewController
    }

    func addNewCondition() {

        viewController.performSegue(withIdentifier: "toConditionPickerModal", sender: nil)
    }

    func updateACondition(healthDescription: HealthDescription) {

        viewController.performSegue(withIdentifier: "toConditionPickerShow", sender: healthDescription)
    }
}
