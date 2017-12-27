//
//  GroupMessage.swift
//  HereYaGo
//
//  Created by Sudhir Bhagat on 23/09/17.
//  Copyright © 2017 DawnShine. All rights reserved.
//
import Foundation
import FirebaseDatabase

class GroupMessage: NSObject
{
    let key: String!
    var messageText: String!
    var messagePhotoUrl: String?
    var messageTime: String?
    var messageUser: String?
    var messageUserId: String!
    var path: String?
    var ref : FIRDatabaseReference?
    init( messageText: String, messagePhotoUrl: String, messageTime: String, messageUser: String, messageUserId: String, key: String = "", dataPath : String!)
    {
        self.key = key
        self.messageText = messageText
        self.messagePhotoUrl = messagePhotoUrl;
        self.messageTime = messageTime
        self.messageUser = messageUser
        self.messageUserId = messageUserId
        self.path = dataPath
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        ref = snapshot.ref
        key = snapshot.key
        path = key
        let data = snapshot.value as! Dictionary<String, Any>
        
        if let newMessageText = data["messageText"] as? String{
            messageText = newMessageText
        }else{
            messageText = ""
        }
        
        if let newMessagePhotoUrl = data["messagePhotoUrl"] as? String{
            messagePhotoUrl = newMessagePhotoUrl
        }else{
            messagePhotoUrl = ""
        }
        
        if let newMessageTime = data["messageTime"] as? String{
            messageTime = newMessageTime
        }else{
            messageTime = ""
        }
        
        if let newMessageUser = data["messageUserName"] as? String{
            messageUser = newMessageUser
        }else{
            messageUser = ""
        }
    
        if let newMessageUserId = data["messageUserId"]
        {
            messageUserId = newMessageUserId as? String
        }else{
            messageUserId = ""
        }
    }
    
    convenience override init()
    {
        self.init( messageText:"", messagePhotoUrl: "", messageTime: "", messageUser: "", messageUserId: "", key : "", dataPath : "")
    }
}
