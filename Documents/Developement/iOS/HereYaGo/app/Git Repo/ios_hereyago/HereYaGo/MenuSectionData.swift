//
//  MenuSectionData.swift
//  HereYaGo
//
//  Created by DawnShine on 15/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import Foundation
import UIKit

class  MenuSectionsData {
    
    func getSectionsFromData() -> [Sections]   {
        
        var sectionsArray = [Sections]()
        
//        @"timeline",@"profile",@"bigpicture",@"community",@"leaderboard",@"giftcards",@"howtoshare",@"settings"
        
        let menus = Sections(title: "",menuitems: ["Timeline","MyProfile","The Big Picture","Community","Leaderboard","My Rewards","How To Share","Setting"],menuimages: ["2","1","3","4","5","6","7","8"])

        
        sectionsArray.append(menus)
        return sectionsArray
    }
}
