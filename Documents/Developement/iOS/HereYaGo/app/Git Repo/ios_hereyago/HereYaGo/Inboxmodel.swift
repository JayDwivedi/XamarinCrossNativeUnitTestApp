//
//  Inboxmodel.swift
//  HereYaGo
//
//  Created by Dawn on 24/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Inboxitem: NSObject{
    let key: String!
    var itemusername: String?
    var itemuserimage: String?
    var itemtitle: String?
    var likesForPost: String!
    var path: String?
    var location : String = ""
    var fromDate : String?
    var status : String?
    var ref : FIRDatabaseReference?
    init( itemusername: String, itemuserimage: String, itemtitle: String,  likesForPost: String, key: String = "", dataPath : String!,location : String = "",fromDate : String!, status : String!) {
        self.key = key
        self.likesForPost = likesForPost
        self.itemusername = itemusername
        self.itemuserimage = itemuserimage
        self.itemtitle = itemtitle
        self.path = dataPath
        self.location = location;
        self.fromDate = fromDate;
        self.status = status;
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        ref = snapshot.ref
        key = snapshot.key
        path = key
        let data = snapshot.value as! Dictionary<String, Any>
        if let newusername = data["name"] as? String{
            itemusername = newusername
        }else{
            itemusername = ""
        }
        if let newuserimage = data["userImg"] as? String{
            itemuserimage = newuserimage
        }else{
            itemuserimage = ""
        }
        if let newitemtitle = data["productid"] as? String{
            itemtitle = newitemtitle
        }else{
            itemtitle = ""
        }
        if let newlike = data["Likes"] as? String{
            likesForPost = newlike
        }else{
            likesForPost = "0"
        }
        if let location1 = data["location"] as? String{
            location = location1
        }else{
            location = "0"
        }
        
        if let fromDate1 = data["fromdate"] as? String{
            fromDate = fromDate1
        }else{
            fromDate = ""
        }
        
        if let status1 = data["status"] as? String{
            status = status1
        }else{
            status = ""
        }
    }
    
    convenience override init() {
        self.init( itemusername:"",itemuserimage: "", itemtitle: "", likesForPost: "", key : "", dataPath : "",location : "",fromDate : "",status : "")
    }
}
