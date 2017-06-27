//
//  AddConditionViewController.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/18/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

class AddConditionViewController: UIViewController {

    @IBOutlet var conditionSegment: UISegmentedControl!
    @IBOutlet var degreeSegment: UISegmentedControl!
    @IBOutlet var locationSegment: UISegmentedControl!
    @IBOutlet var descriptionTextField: UITextField!

    @IBAction func submitConditionButtonPressed(_ sender: UIButton) {

        // Nothing to do here so far
    }

//    func getCondition() -> HealthCondition {
//
//        let conditionAndLocation: HealthCondition = HealthCondition(condition: conditionSegment.selectedSegmentIndex, degree: degreeSegment.selectedSegmentIndex, location: locationSegment.selectedSegmentIndex, description: descriptionTextField.text)
//
//        return conditionAndLocation
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
