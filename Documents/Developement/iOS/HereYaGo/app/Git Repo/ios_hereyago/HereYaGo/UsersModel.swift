//
//  UsersModel.swift
//  HereYaGo
//
//  Created by Dawn on 15/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Usersdetails: NSObject
{
    let key: String!
    var username: String?
    var nickname: String?
    var userimage: String?
    var likesForPost: String!
    var sharesForPost: String!
    var userid : String?
    var userPoints: Int?
    var userBadges: String?
    var userRank: String?
    var userCity: String?
    var usercountry: String?
    var userhouse: String?
    var userstreet: String?
    var userstate: String?
    var usermobile: String?
    var userzip: String?
    var userlongitutue: String?
    var userLattitute: String?
    var path: String?
    var ref : FIRDatabaseReference?
    init( username: String, userimage: String, nickname: String, userid: String, userPoints: Int, userBadges: String, userRank: String,userCity: String,   usercountry: String, userhouse: String, userstreet: String, userstate: String , usermobile: String, userzip: String, userlongitutue: String, userLattitute: String,  likesForPost: String,sharesForPost : String, key: String = "", dataPath : String!) {
        self.key = key
        self.likesForPost = likesForPost
        self.sharesForPost = sharesForPost;
        self.username = username
        self.userimage = userimage
        self.nickname = nickname
        self.path = dataPath
        self.userid = userid
        self.userBadges = userBadges
        self.userPoints = userPoints
        self.userRank = userRank
        self.userCity = userCity
        self.userhouse = userhouse
        self.userstreet = userstreet
        self.userstate = userstate
        self.usercountry = usercountry
        self.usermobile = usermobile
        self.userzip = userzip
        self.userlongitutue = userlongitutue
        self.userLattitute = userLattitute
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        ref = snapshot.ref
        key = snapshot.key
        path = key
        let data = snapshot.value as! Dictionary<String, Any>
        if let newusername = data["userName"] as? String{
            username = newusername
        }else{
            username = ""
        }
        if let newuserimage = data["userProfilePic"] as? String{
            userimage = newuserimage
        }else{
            userimage = ""
        }
        if let newinickname = data["userNickName"] as? String{
            nickname = newinickname
        }else{
            nickname = ""
        }
        
        if let newuserid = data["id"] as? String{
            userid = newuserid
        }else{
            userid = ""
        }
        print(data)
       userBadges = ""
        
        var badgesDict : [String: AnyObject] ;
        if let newBadgesArr = data["Badges"]
        {
            badgesDict = newBadgesArr as! [String : AnyObject]
            userBadges = String(format:" %i",badgesDict.count);
            print("Badge count : \(String(describing: userBadges))")
        }else{
            userBadges = "0"
        }
      
        if let newuserpoints = data["Points"] {
            userPoints = newuserpoints as? Int
        }else{
            userPoints = 0
        }

        if let newuserrank = data["rank"] as? String{
            userRank = newuserrank
        }else{
            userRank = "0"
        }
        if let newcity = data["city"] as? String{
            userCity = newcity
        }else{
            userCity = ""
        }
        
        if let sharesForPost1 = data["Myshares"] as? String{
            sharesForPost = sharesForPost1
        }else{
            sharesForPost = ""
        }
        if let newuserhouse = data["houseNumber"] as? String{
            userhouse = newuserhouse
        }else{
            userhouse = ""
        }
        if let newuserstreet = data["street"] as? String{
            userstreet = newuserstreet
        }else{
            userstreet = ""
        }
        if let newuserstate = data["state"] as? String{
            userstate = newuserstate
        }else{
            userstate = ""
        }
        if let newusercountry = data["country"] as? String{
            usercountry = newusercountry
        }else{
            usercountry = ""
        }
        
        if let newusermobile = data["userMobileNumber"] as? String{
            usermobile = newusermobile
        }else{
            usermobile = ""
        }
        
        if let newuserzip = data["zipCode"] as? String{
            userzip = newuserzip
        }else{
            userzip = "0"
        }
        if let newuserlongitutute = data["longitute"] as? String{
            userlongitutue = newuserlongitutute
        }else{
            userlongitutue = ""
        }
        if let newuserlattitute = data["latitude"] as? String{
            userLattitute = newuserlattitute
        }else{
            userLattitute = ""
        }
    }
    
    convenience override init() {
        self.init( username:"", userimage: "", nickname: "",userid:"", userPoints: 0, userBadges: "", userRank: "" , userCity: "", usercountry: "", userhouse: "", userstreet: "", userstate: "", usermobile: "", userzip: "", userlongitutue: "", userLattitute: "", likesForPost: "",sharesForPost: "", key : "", dataPath : "")
}
}
