//
//  ImageTableViewCell.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/20/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

class ImageTableViewCell: CustomTableViewCell {

    @IBOutlet var medicalImage: UIImageView!
    @IBOutlet var testLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        adjustLeadingConstraint(constant: 0.0)

        hideExtraContent()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        hideExtraContent()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func showExtraContent() {

        medicalImage.isHidden = false
    }

    override func hideExtraContent() {

        medicalImage.isHidden = true
    }

    override func loadPrintMode(row: Int, delegate: TableViewDataSource, selected: Bool) {
        super.loadPrintMode(row: row, delegate: delegate, selected: selected)

        adjustLeadingConstraint(constant: 50.0)
    }

    override func loadDefaultMode() {
        super.loadDefaultMode()

        adjustLeadingConstraint(constant: 0.0)
    }

    func adjustLeadingConstraint(constant: CGFloat) {

        if labelLeadingConstr != nil {

            self.removeConstraint(labelLeadingConstr)
        }

        labelLeadingConstr = testLabel.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor, constant: constant)
        labelLeadingConstr.isActive = true
    }
}
