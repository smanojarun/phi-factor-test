//
//  PFSiginuptablecellTableViewCell.swift
//  PhiFactor
//
//  Created by Apple on 20/05/16.
//  Copyright © 2016 Apple. All rights reserved.
//

import UIKit

class PFSiginuptablecellTableViewCell: UITableViewCell {

    @IBOutlet weak var celltextchossen: UITextField!
    @IBOutlet weak var cellstepdiscloserbutton: UIButton!
    @IBOutlet weak var celldiscloserbutton: UIButton!
    @IBOutlet weak var celltextdetails: UILabel!
    @IBOutlet weak var cellimage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
