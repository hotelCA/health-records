//
//  ImageTableViewCell.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/20/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    @IBOutlet var medicalImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        medicalImage.isHidden = true
        // Initialization code
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
}
