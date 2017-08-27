//
//  DescriptionTableViewCell.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/20/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

class DescriptionTableViewCell: CustomTableViewCell {

    @IBOutlet var MedicalDescriptionLabel: UILabel!
    @IBOutlet var arrowImage: UIImageView!
    @IBOutlet var tagsHorizontalStack: UIStackView!
    @IBOutlet var stackViewWidth: NSLayoutConstraint!

    override func layoutSubviews() {
        super.layoutSubviews()

        //        let contentViewBound = self.contentView.bounds

        var imageViewFrame = self.imageView?.frame

        imageViewFrame?.origin.y = 15

        self.imageView?.frame = imageViewFrame!
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        let firstLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: tagsHorizontalStack.frame.height / 2.0))
        firstLabel.text = "first"
        firstLabel.textAlignment = .center
        firstLabel.layer.backgroundColor = UIColor.brown.cgColor
        firstLabel.layer.cornerRadius = 5
        firstLabel.layer.masksToBounds = true

        let secondLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: tagsHorizontalStack.frame.height / 2.0))
        secondLabel.text = "second"
        secondLabel.textAlignment = .center
        secondLabel.layer.backgroundColor = UIColor.purple.cgColor
        secondLabel.layer.cornerRadius = 5
        secondLabel.layer.masksToBounds = true

        stackViewWidth.constant = firstLabel.intrinsicContentSize.width + secondLabel.intrinsicContentSize.width + 5 + 20
        tagsHorizontalStack.addArrangedSubview(firstLabel)
        tagsHorizontalStack.addArrangedSubview(secondLabel)
        tagsHorizontalStack.spacing = 5
        tagsHorizontalStack.distribution = .fillProportionally
        tagsHorizontalStack.alignment = .fill

        adjustLeadingConstraint(constant: 50.0)

        setAvatar()
        rotateArrow(duration: 0.2, angle: Double.pi/2)

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

        tagsHorizontalStack.isHidden = false
    }

    override func hideExtraContent() {

        tagsHorizontalStack.isHidden = true
    }

    override func loadPrintMode(row: Int, delegate: TableViewDataSource, selected: Bool) {
        super.loadPrintMode(row: row, delegate: delegate, selected: selected)

        adjustLeadingConstraint(constant: 50.0)
        clearAvatar()
    }

    override func loadDefaultMode() {
        super.loadDefaultMode()

        adjustLeadingConstraint(constant: 50.0)

        setAvatar()
    }

    func adjustLeadingConstraint(constant: CGFloat) {

        if labelLeadingConstr != nil {

            self.removeConstraint(labelLeadingConstr)
        }

        labelLeadingConstr = MedicalDescriptionLabel.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor, constant: constant)
        labelLeadingConstr.isActive = true
    }

    func setAvatar() {

        let image = UIImage(named: "description.png")
        self.imageView?.image = image?.resizeImage(targetSize: CGSize(width: 30.0, height: 30.0))
    }

    func clearAvatar() {

        self.imageView?.image = nil
    }
}

extension DescriptionTableViewCell {
    fileprivate func rotateArrow(duration: TimeInterval, angle: Double) {

        UIView.animate(withDuration: duration, animations: {
            self.arrowImage.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(angle)) / 180.0)
        })
    }
}
