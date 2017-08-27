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
    @IBOutlet var expandArrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        adjustLeadingConstraint(constant: 0.0)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        collapse()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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

        labelLeadingConstr = headerLabel.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor, constant: constant)
        labelLeadingConstr.isActive = true
    }

    func collapse() {

        rotateArrow(duration: 0.2, angle: 0.0001)
    }

    func expand() {

        rotateArrow(duration: 0.2, angle: Double.pi)
    }
}

extension HeaderViewCell {

    fileprivate func rotateArrow(duration: TimeInterval, angle: Double) {

        UIView.animate(withDuration: duration, animations: {
            self.expandArrow.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(angle)) / 180.0)
        })
    }
}
