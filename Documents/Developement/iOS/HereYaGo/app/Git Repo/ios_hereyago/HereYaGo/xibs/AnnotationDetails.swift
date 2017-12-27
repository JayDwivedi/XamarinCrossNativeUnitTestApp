//
//  AnnotationDetails.swift
//  HereYaGo
//
//  Created by Ajay Dhasal on 15/08/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import UIKit

class AnnotationDetails: UIView {

    
    @IBOutlet weak var imageProduct: UIImageView!
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblComments: UILabel!
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var lblLikesCount: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    class func instanceFromNib() -> AnnotationDetails {
        return UINib(nibName: "AnnotationDetails", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView as! AnnotationDetails
    }
}
