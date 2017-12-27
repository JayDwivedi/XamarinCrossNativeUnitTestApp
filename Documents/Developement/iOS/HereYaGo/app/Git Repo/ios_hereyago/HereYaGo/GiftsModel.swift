//
//  GiftsModel.swift
//  HereYaGo
//
//  Created by Dawn on 18/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Giftsitem: NSObject{
    let key: String!
    var date: String?
    var giftdescription: String?
    var userid: String?
    var giftimage: String?
    var giftlogopath: String?
    var gifttitle: String?
    var giftvalue: String?
    var couponCode: String?
    var path: String?
    var ref : FIRDatabaseReference?
    init( date: String, giftdescription: String, userid: String, giftimage: String, giftlogopath: String, gifttitle: String, giftvalue: String, couponCode: String, key: String = "", dataPath : String!) {
        self.key = key
        self.date  = date
        self.giftdescription = giftdescription
        self.userid = userid
        self.giftimage = giftimage
        self.giftlogopath = giftlogopath
        self.gifttitle = gifttitle
        self.giftvalue = giftvalue
        self.path = dataPath
        self.couponCode = couponCode;
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot)
    {
        ref = snapshot.ref
        key = snapshot.key
        path = key
        let data = snapshot.value as! Dictionary<String, Any>
        
        if let newdate = data["startDate"] as? String{
           date  = newdate
        }else{
            date = ""
        }
        
        if let newdate = data["coupcode"] as? String{
            couponCode  = newdate
        }else{
            couponCode = ""
        }

        
        if let newgiftdescription = data["desc"] as? String{
            giftdescription = newgiftdescription
        }else{
            giftdescription = ""
        }
        
        if let newuserid = data["id"] as? String{
            userid = newuserid
        }else{
            userid = ""
        }
        
        if let newgiftimage = data["imgUrl"] as? String{
            giftimage = newgiftimage
        }else{
            giftimage = ""
        }
        
        if let newgiftlogo = data["logoPath"] as? String{
            giftlogopath = newgiftlogo
        }else{
            giftlogopath = ""
        }
        
        if let newgifttitle = data["name"] as? String{
            gifttitle = newgifttitle
        }else{
            giftimage = ""
        }
        
        if let newgifvalue = data["salecomission"] as? String{
            giftvalue = newgifvalue
        }else{
            giftvalue = ""
        }
    }
    
    convenience override init() {
        self.init(date:"", giftdescription: "", userid: "", giftimage: "", giftlogopath: "", gifttitle: "", giftvalue: "",couponCode: "", key : "", dataPath : "")
    }
}
