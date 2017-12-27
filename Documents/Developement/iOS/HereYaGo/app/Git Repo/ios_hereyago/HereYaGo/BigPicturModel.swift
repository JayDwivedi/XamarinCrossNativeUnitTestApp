//
//  BigPicturModel.swift
//  HereYaGo
//
//  Created by Dawn on 18/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import Foundation
import FirebaseDatabase

class BigPictureitem: NSObject{
    let key: String!
    var date : String?
    var Bpdescription: String?
    var userid: String?
    var imagedescription: String?
    var imageurl: String?
    var Bplogopath: String?
    var BPtitle: String?
    var path: String?
    var ref : FIRDatabaseReference?
    init( date: String, Bpdescription: String, userid: String, imagedescription: String,imageurl: String, Bplogopath: String, Bptitle: String, key: String = "", dataPath : String!) {
        self.key = key
        self.date = date
        self.Bpdescription = Bpdescription
        self.userid = userid
        self.imagedescription = imagedescription
        self.imageurl = imageurl
        self.Bplogopath = Bplogopath
        self.BPtitle = Bptitle
        self.path = dataPath
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        ref = snapshot.ref
        key = snapshot.key
        path = key
        let data = snapshot.value as! Dictionary<String, Any>
        if let newdate = data["date"] as? String{
            date = newdate
        }else{
            date = ""
        }
        if let newbpdescription = data["description"] as? String{
            Bpdescription = newbpdescription
        }else{
            Bpdescription = ""
        }
        if let newuserid = data["uid"] as? String{
            userid = newuserid
        }else{
            userid = ""
        }
        
        if let newimageurl = data["imgUrl"] as? String{
            imageurl = newimageurl
        }else{
            imageurl = ""
        }
        if let newimagedescription = data["imageDescription"] as? String{
            imagedescription = newimagedescription
        }else{
            imagedescription = ""
        }
        if let newbplogopath = data["logoPath"] as? String{
            Bplogopath = newbplogopath
        }else{
            Bplogopath = ""
        }
        if let newbptitle = data["title"] as? String{
            BPtitle = newbptitle
        }else{
            BPtitle = ""
        }
        
    }
    
    convenience override init() {
        self.init( date:"", Bpdescription: "", userid: "", imagedescription: "", imageurl: "", Bplogopath: "", Bptitle: "", key : "", dataPath : "")
    }
}
