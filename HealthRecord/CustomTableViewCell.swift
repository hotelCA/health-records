//
//  TableViewCellExtension.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 7/5/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    var labelLeadingConstr: NSLayoutConstraint!
    var checkButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {

        loadDefaultMode()
    }

    func loadPrintMode() {

        createCheckButton()
    }

    func loadDefaultMode() {

        removeCheckButton()
    }
    
    func createCheckButton() {

        checkButton = UIButton(frame: CGRect(x: 8, y: 8, width: 30, height: 30))
        checkButton.layer.cornerRadius = 15
        checkButton.layer.masksToBounds = true
        checkButton.adjustsImageWhenHighlighted = false
        checkButton.setBackgroundImage(UIImage(named: "uncheck_circle.png"), for: .normal)
        checkButton.setBackgroundImage(UIImage(named: "check_mark.png"), for: .selected)
        checkButton.addTarget(self, action: #selector(ImageTableViewCell.checkButtonPressed), for: UIControlEvents.touchUpInside)

        self.addSubview(checkButton)
    }

    func checkButtonPressed() {

        if checkButton.isSelected {

            checkButton.isSelected = false

        } else {

            checkButton.isSelected = true
        }
    }

    func removeCheckButton() {

        if checkButton != nil {

            checkButton.removeFromSuperview()
        }
    }
}


extension UITableViewCell {

    func showExtraContent() {

        // Override this function
    }

    func hideExtraContent() {

        // Override this function
    }
}
