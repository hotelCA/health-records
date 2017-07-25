//
//  HeaderViewCell.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 7/2/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

class HeaderViewCell: CustomTableViewCell {

    @IBOutlet var headerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        adjustLeadingConstraint(constant: 0.0)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func loadPrintMode(row: Int, delegate: TableViewDataSource) {
        super.loadPrintMode(row: row, delegate: delegate)

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

        labelLeadingConstr = headerLabel.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor, constant: constant)
        labelLeadingConstr.isActive = true
    }
}
