//
//  CustomTableViewCell.swift
//  Notes App
//
//  Created by Shashwat  on 12/03/19.
//  Copyright © 2019 Shashwat . All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel! {
        didSet{
            titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.font = UIFont.preferredFont(forTextStyle: .body)
        }
    }
    @IBOutlet weak var createdLabel: UILabel! {
        didSet {
            createdLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
            createdLabel.textColor = UIColor.lightGray
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .body)
        createdLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
    }
    
}
