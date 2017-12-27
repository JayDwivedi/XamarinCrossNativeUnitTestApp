//
//  NearByModel.swift
//  HereYaGo
//
//  Created by Sudhir Bhagat on 15/08/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import Foundation
import FirebaseDatabase

class nearbyitem: NSObject
{
    var itemusername: String?
    var userid:String!
    var latitude:String!
    var longitude:String!
    var share:String!
    var sharesArr :Array = [Any]()

    var ref : FIRDatabaseReference?
    init( itemusername: String, itemdes: String, itemtitle: String, itemimage: String, postdate: String, itemcategory: String,  likesForPost: String, key: String = "", dataPath : String!, itemuserimage : String!, userRank: String!, userBadge: String!, userID: String!, commentsCount: String!, userPoints: String!)
    {
        self.itemusername = itemusername
        self.ref = nil
        self.latitude = nil
        self.longitude = nil
    }
    
    init(snapshot: FIRDataSnapshot)
    {
        ref = snapshot.ref
        let data = snapshot.value as! Dictionary<String, Any>
        if let newusername = data["userName"] as? String{
            itemusername = newusername
        }else{
            itemusername = "Test User Namae"
        }
        if let newuserid = data["id"] as? String{
            userid = newuserid
        }else{
            userid = ""
        }
        
        if let newSharesArr = data["Myshares"]
        {
            sharesArr = [newSharesArr]
        }
        
        if let newLatitude = data["latitude"]
        {
            latitude = String( describing: newLatitude)
        }else{
            latitude = nil
        }
        
        if let newlongitude = data["longitude"]
        {
            longitude = String( describing: newlongitude)
        }else{
            longitude = nil
        }
        print(data)
    }
    
    convenience override init()
    {
        self.init( itemusername:"",itemdes: "", itemtitle: "", itemimage: "" , postdate:"", itemcategory: "", likesForPost: "", key : "", dataPath : "", itemuserimage : "", userRank : "", userBadge : "", userID : "", commentsCount : "", userPoints: "" )
    }
}
