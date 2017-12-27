//
//  InboxTableViewCell.swift
//  HereYaGo
//
//  Created by Dawn on 24/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import UIKit

class InboxTableViewCell: UITableViewCell {

    @IBOutlet var producttitle: UILabel!
    @IBOutlet var username: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var profilePicImageview: UIImageView!
    
    @IBOutlet weak var heightForLocations: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profilePicImageview.layer.cornerRadius = self.profilePicImageview.frame.size.width/2;
        profilePicImageview.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
