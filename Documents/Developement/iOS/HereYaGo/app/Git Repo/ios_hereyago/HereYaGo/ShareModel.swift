//
//  Shares.swift
//  HereYaGo
//
//  Created by Dawn on 15/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import Foundation
import FirebaseDatabase

class LikesItem: NSObject
{
    let key: String! = nil
    var itemuserimage: String?

    init(snapshot: FIRDataSnapshot)
    {
        
    }
}

class shareitem: NSObject
{
    let key: String!
    var itemuserimage: String?
    var userid: String?
    var itemusername: String?
    var userRank: String?
    var userBadge : String?
    var itemdes: String?
    var itemtitle: String?
    var itemimage: String?
    var itemcategory: String?
    var likesForPost: String?
    var postdate: String!
    var commentsCount: String!
    var userPoints: Int!
    var path: String?
    var likesCount:String!
    var userUUID: String!
    var latitude:String!
    var longitude:String!
    var productKey:String!
    var numOfDays:String!

    var ref : FIRDatabaseReference?
    init( itemusername: String, itemdes: String, itemtitle: String, itemimage: String, postdate: String, itemcategory: String,  likesForPost: String, key: String = "", dataPath : String!, itemuserimage : String!, userRank: String!, userBadge: String!, userID: String!, commentsCount: String!, userPoints: Int) {
        self.key = key
        self.likesForPost = likesForPost
        self.itemusername = itemusername
        self.itemdes = itemdes
        self.itemtitle = itemtitle
        self.itemimage = itemimage
        self.itemcategory = itemcategory
        self.postdate = postdate
        self.path = dataPath
        self.itemuserimage = itemuserimage
        self.userRank = userRank
        self.userBadge = userBadge
        self.userid = userID
        self.commentsCount = commentsCount;
        self.userPoints = userPoints
        self.ref = nil
        self.likesCount = "0"
        self.latitude = nil
        self.longitude = nil
        self.productKey = nil
        self.numOfDays = nil
    }
    
    init(snapshot: FIRDataSnapshot)
    {
        ref = snapshot.ref
        key = snapshot.key
        path = key
        let data = snapshot.value as! Dictionary<String, Any>
        if let newusername = data["userName"] as? String{
            itemusername = newusername
        }else{
            itemusername = "Test User Namae"
        }
        if let newuserid = data["uid"] as? String{
            userid = newuserid
        }else{
            userid = ""
        }
        if let newitemdes = data["strDescription"] as? String{
            itemdes = newitemdes
        }else{
            itemdes = ""
        }
        if let newitemtitle = data["title"] as? String{
            itemtitle = newitemtitle
        }else{
            itemtitle = ""
        }
        if let newitemimage = data["imgUrl"] as? String{
            itemimage = newitemimage
        }else{
            itemimage = ""
        }
        if let newdate = data["date"] as? String{
            postdate = newdate
        }else{
            postdate = ""
        }
        if let newcategory = data["category"] as? String{
            itemcategory = newcategory
        }else{
            itemcategory = ""
        }
        if let newlike = data["Likes"] as? String{
            likesForPost = newlike
        }else{
            likesForPost = "0"
        }
        
        if let newuserimage = data["userProfileIcon"] as? String{
             itemuserimage = newuserimage
        }else{
            itemuserimage = ""
        }
        
        if let newuserrank = data["userRank"] as? String{
            userRank = newuserrank
        }else{
            userRank = "0"
        }
        if let newuserbadge = data["userBadge"] as? String{
            userBadge = newuserbadge
        }else{
            userBadge = "0"
        }
        if let newCommentCount = data["commentsCount"] as? String
        {
            commentsCount = newCommentCount
        }else{
            commentsCount = "0"
        }
        if let newuserPoints = data["Points"] 
        {
            userPoints = newuserPoints as! Int
        }else{
            userPoints = 0
        }
        
        if let newlikeCount = data["likesCount"]
        {
            likesCount =  String(format : "%@",newlikeCount as! CVarArg)
        }else{
            likesCount = "0"
        }
        
        if let newProductKey = data["productKey"]
        {
            productKey =  String(format : "%@",newProductKey as! CVarArg)
        }else{
            productKey = "0"
        }

        if let newCommentsCount = data["commentsCount"]
        {
            commentsCount = String(format : "%@",newCommentsCount as! CVarArg)
        }else{
            commentsCount = "0 "
        }
        
        if let newLatitude = data["latitude"]
        {
            latitude = newLatitude as! String
        }else{
            latitude = nil
        }
        
        if let newlongitude = data["longitude"]
        {
            longitude = newlongitude as! String
        }else{
            latitude = nil
        }

        if let newUUID = data["id"] as? String
        {
            userUUID = newUUID
        }
        
        if let newNumDays = data["numDays"] as? String
        {
            numOfDays = newNumDays
        }
    }
    
    convenience override init()
    {
        self.init( itemusername:"",itemdes: "", itemtitle: "", itemimage: "" , postdate:"", itemcategory: "", likesForPost: "", key : "", dataPath : "", itemuserimage : "", userRank : "", userBadge : "", userID : "", commentsCount : "", userPoints: 0 )
    }
}
