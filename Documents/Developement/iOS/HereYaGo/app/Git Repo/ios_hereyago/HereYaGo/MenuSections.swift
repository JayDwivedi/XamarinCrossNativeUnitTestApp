//
//  MenuSections.swift
//  HereYaGo
//
//  Created by DawnShine on 15/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import Foundation
import UIKit


struct Sections{
    var headings : String
    var menuItems : [String]
    var menuImages : [String]
    
    
    init(title : String,menuitems : [String],menuimages:[String]){
        headings = title
        menuItems = menuitems
        menuImages = menuimages
    }
    
}
