//
//  CommentsTableViewCell.swift
//  HereYaGo
//
//  Created by Dawn on 17/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {

    @IBOutlet var userImage: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet var sendTime: UILabel!
    @IBOutlet var commentText: UILabel!
    @IBOutlet var btnReply: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
