//
//  AddConditionViewController.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/18/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

protocol AddConditionViewControllerProtocol {

    func createNewHealthDescription(healthDescription: HealthDescription)
}

class AddConditionViewController: UIViewController {

    @IBOutlet var conditionSegment: UISegmentedControl!
    @IBOutlet var degreeSegment: UISegmentedControl!
    @IBOutlet var locationSegment: UISegmentedControl!
    @IBOutlet var descriptionTextField: UITextField!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var cancelButton: UIButton!

    var delegate: AddConditionViewControllerProtocol!
    var updateMode: Bool!
    var healthDescription: HealthDescription!

    @IBAction func cancelPressed(_ sender: Any) {

        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveConditionPressed(_ sender: Any) {

        let healthDescription = HealthDescription(timeOfDescription: Date(), condition: ConditionEnum(rawValue: conditionSegment.selectedSegmentIndex)!)

        delegate.createNewHealthDescription(healthDescription: healthDescription)

        self.dismiss(animated: true, completion: nil)
    }

    func updateView(healthDescription: HealthDescription) {

        self.healthDescription = healthDescription
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if updateMode {

            saveButton.isHidden = true
            cancelButton.isHidden = true
            conditionSegment.selectedSegmentIndex = healthDescription.condition.rawValue

        } else {

            saveButton.isHidden = false
            saveButton.isHidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
