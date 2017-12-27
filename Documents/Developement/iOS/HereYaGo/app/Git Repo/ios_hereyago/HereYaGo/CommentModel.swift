//
//  CommentModel.swift
//  HereYaGo
//
//  Created by Dawn on 15/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import Foundation
import FirebaseDatabase

class commentitem: NSObject{
    let key: String!
    var itemusername: String?
    var itemuserimage: String?
    var commenttext:  String?
    var date : String?
    var likesForPost: String!
    var path: String?
    var ref : FIRDatabaseReference?
    init( itemusername: String, itemuserimage: String, commenttext: String, date: String,  likesForPost: String, key: String = "", dataPath : String!) {
        self.key = key
        self.likesForPost = likesForPost
        self.itemusername = itemusername
        self.itemuserimage = itemuserimage
        self.commenttext = commenttext
        self.date = date
        self.path = dataPath
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        ref = snapshot.ref
        key = snapshot.key
        path = key
        let data = snapshot.value as? Dictionary<String, String>
        if let newusername = data?["uid"] {
            itemusername = newusername
        }else{
            itemusername = ""
        }
        if let newuserimage = data?["userProfilePic"] {
            itemuserimage = newuserimage
        }else{
            itemuserimage = ""
        }
        if let newitemtitle = data?["comment"] {
            commenttext = newitemtitle
        }else{
            commenttext = ""
        }
        if let sendtime = data?["date"] {
            date = sendtime
        }else{
            date = ""
        }
        if let newlike = data?["Likes"]{
            likesForPost = newlike
        }else{
            likesForPost = "0"
        }
        
    }
    
    convenience override init() {
        self.init( itemusername:"",itemuserimage: "", commenttext: "", date: "", likesForPost: "", key : "", dataPath : "")
    }
}

