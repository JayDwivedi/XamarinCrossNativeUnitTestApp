//
//  ProfileViewControllerCell.swift
//  HereYaGo
//
//  Created by DawnShine on 15/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import Foundation
import UIKit

class ProfileViewControllerCell : UITableViewCell{
    
    
    
    @IBOutlet weak var lblComments: UILabel!
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var lblLikesCount: UILabel!
    
    @IBOutlet var imgMember: UIImageView!
    @IBOutlet var lblMemberName: UILabel!
    @IBOutlet var lblMemberDetails: UILabel!
    @IBOutlet var btnRateProduct: UIButton!
    @IBOutlet var lblProductName: UILabel!

    @IBOutlet var lbldate: UILabel!
    @IBOutlet var lblProductDescription: UILabel!
    @IBOutlet var imgProduct: UIImageView!
    @IBOutlet var btnTopShare: UIButton!
    @IBOutlet var btnLike: UIButton!
    @IBOutlet var btnComment: UIButton!
    @IBOutlet var btnPoints: UIButton!
    var pathDB : String!
}
