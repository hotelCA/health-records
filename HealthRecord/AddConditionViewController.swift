//
//  AddConditionViewController.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/18/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

protocol AddConditionViewControllerDelegate {

    func createNewHealthDescription(healthDescription: HealthDescription)
}

class AddConditionViewController: UIViewController {

    @IBOutlet var conditionSegment: UISegmentedControl!
    @IBOutlet var degreeSegment: UISegmentedControl!
    @IBOutlet var locationSegment: UISegmentedControl!
    @IBOutlet var descriptionTextField: UITextField!

    var delegate: AddConditionViewControllerDelegate!

    @IBAction func submitConditionButtonPressed(_ sender: UIButton) {

        
        // Nothing to do here so far
    }

    func getNewCondition() -> HealthDescription {

        return HealthDescription(timeOfDescription: Date(), condition: ConditionEnum(rawValue: conditionSegment.selectedSegmentIndex)!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
