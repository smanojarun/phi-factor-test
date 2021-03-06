//
//  PFUploadTableViewCell.swift
//  PhiFactor
//
//  Created by Apple on 30/05/16.
//  Copyright © 2016 Hubino. All rights reserved.
//

import UIKit

class PFUploadTableViewCell: UITableViewCell {

    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var uploadStatus: UILabel!
    @IBOutlet var patientIdLabel: UILabel!
    @IBOutlet var videoName: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
