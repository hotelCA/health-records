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

    override func layoutSubviews() {
        super.layoutSubviews()

//        let contentViewBound = self.contentView.bounds

//        var imageViewFrame = self.imageView?.frame
//
//        imageViewFrame?.origin.y = 15

        self.imageView?.frame.origin.y = 15
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setAvatar()

        adjustLeadingConstraint(constant: 50.0)

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
        clearAvatar()
    }

    override func loadDefaultMode() {
        super.loadDefaultMode()

        setAvatar()

        adjustLeadingConstraint(constant: 50.0)
    }

    func adjustLeadingConstraint(constant: CGFloat) {

        if labelLeadingConstr != nil {

            self.removeConstraint(labelLeadingConstr)
        }

        labelLeadingConstr = testLabel.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor, constant: constant)
        labelLeadingConstr.isActive = true
    }

    func setAvatar() {

        let image = UIImage(named: "image.png")
        self.imageView?.image = image?.resizeImage(targetSize: CGSize(width: 30.0, height: 30.0))
    }

    func clearAvatar() {

        self.imageView?.image = nil
    }
}
