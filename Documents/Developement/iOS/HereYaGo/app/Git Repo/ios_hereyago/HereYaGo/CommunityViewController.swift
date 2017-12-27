 //
//  CommunityViewController.swift
//  HereYaGo
//
//  Created by DawnShine on 16/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class CommunityViewControler: UIViewController,UITableViewDelegate,UITableViewDataSource
{
    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet var CommunityTable: UITableView!
    @IBOutlet var MembersBtn: UIButton!
    @IBOutlet var MessagesBtn: UIButton!
    @IBOutlet var changelabel: UILabel!
    @IBOutlet var MembersView: UIView!

    @IBOutlet var viewForMsgTextField: UIView!
    @IBOutlet var textFieldMessage: UITextField!
    
    @IBOutlet weak var GroupChatTable: UITableView!
    
    //var groupChatItems = [[String: Any]]()
    var groupChatItems : [GroupMessage] = []
    var communitydata = [Usersdetails]()
    var ref = FIRDatabaseReference()
    var storageref = FIRStorageReference()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if revealViewController() != nil
        {
            // revealViewController().rearViewRevealWidth = 62
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            revealViewController().rightViewRevealWidth = 150
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.CommunityTable.isHidden = false
        self.GroupChatTable.isHidden = true
        self.viewForMsgTextField.isHidden = true
        
        self.GroupChatTable.dataSource = self
        self.GroupChatTable.delegate = self
        self.GroupChatTable.reloadData()
        self.getcommunitydata()
        self.getGroupChatData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func ButtonActiontapped(_ sender: UIButton)
    {
        let buttontitle = sender.tag
        switch  buttontitle {
        case 100:
          self.getcommunitydata()
            UIView.animate(withDuration: 0.5, animations: {
                self.CommunityTable.isHidden = false
                self.GroupChatTable.isHidden = true
                self.viewForMsgTextField.isHidden = true
                self.changelabel.frame = CGRect(x: self.MembersBtn.frame.origin.x, y: self.changelabel.frame.origin.y, width: self.MembersBtn.frame.size.width, height: self.changelabel.frame.size.height )
                self.MembersBtn
                    .backgroundColor = UIColor.init(colorLiteralRed: 5.0/255.0, green: 46.0/255.0, blue: 89.0/255.0, alpha: 1)
                self.MessagesBtn.backgroundColor = UIColor.init(colorLiteralRed: 9.0/255.0, green: 71.0/255.0, blue: 138.0/255.0, alpha: 1)
                
            })
            
            break
        case 200:
           self.getGroupChatData()
            UIView.animate(withDuration: 0.5, animations: {
                self.CommunityTable.isHidden = true
                self.GroupChatTable.isHidden = false
                self.viewForMsgTextField.isHidden = false
                self.changelabel.frame = CGRect(x: self.MessagesBtn.frame.origin.x, y: self.changelabel.frame.origin.y, width: self.MessagesBtn.frame.size.width, height: self.changelabel.frame.size.height )
                self.MessagesBtn.backgroundColor = UIColor.init(colorLiteralRed: 5.0/255.0, green: 46.0/255.0, blue: 89.0/255.0, alpha: 1)
                self.MembersBtn.backgroundColor = UIColor.init(colorLiteralRed: 9.0/255.0, green: 71.0/255.0, blue: 138.0/255.0, alpha: 1)
                
            })
            break
        default:
           self.getcommunitydata()
            UIView.animate(withDuration: 0.5, animations: {
                
                self.CommunityTable.isHidden = false
                self.GroupChatTable.isHidden = true
                self.viewForMsgTextField.isHidden = true
                self.changelabel.frame = CGRect(x: self.MembersBtn.frame.origin.x, y: self.changelabel.frame.origin.y, width: self.MembersBtn.frame.size.width, height: self.changelabel.frame.size.height )
                self.MembersBtn
                    .backgroundColor = UIColor.init(colorLiteralRed: 5.0/255.0, green: 46.0/255.0, blue: 89.0/255.0, alpha: 1)
                self.MessagesBtn.backgroundColor = UIColor.init(colorLiteralRed: 9.0/255.0, green: 71.0/255.0, blue: 138.0/255.0, alpha: 1)
                
            })
            break
        }
    }
    
    @IBAction func actionSendMessage(_ sender: Any)
    {
        let msgText = self.textFieldMessage.text!
        let trimmedMessageString = msgText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedMessageString.characters.count > 0
        {
            var ref = FIRDatabase.database().reference()
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateStyle = .medium
            dateFormatter1.dateFormat = "dd-MM-yyyy"
            let date = dateFormatter1.string(from: NSDate() as Date)
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .medium
            timeFormatter.dateFormat = "hh:mm:ss a"
            let time = timeFormatter.string(from: Date() as Date)
            let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
            // let userName =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserName)! as! String
            let userName =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserName)! as! String
            
            let commentinfo : Dictionary<String, Any> = ["messageUserName":userName,
                                                         "messagePhotoUrl": userID,
                                                         "messageTime": "\(date) \(time)",
                "messageUserId":userID,
                "messageText":trimmedMessageString]
            ref.child("GroupMessages").childByAutoId().setValue(commentinfo)
            self.textFieldMessage.text = ""
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == self.CommunityTable
        {
            return self.communitydata.count
        }
        else
        {
            return self.groupChatItems.count;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell : UITableViewCell?
        if tableView == self.CommunityTable
        {
            var communitycell : CommunityCell = CommunityTable.dequeueReusableCell(withIdentifier: "communitycells", for: indexPath) as! CommunityCell
            var mycommunity = Usersdetails()
            mycommunity = communitydata[indexPath.row]

            communitycell.lblMemberName.text = mycommunity.username
            if  !(mycommunity.userimage!.isEmpty)
            {
                communitycell.imgUser.sd_setImage(with: URL(string: mycommunity.userimage!), placeholderImage: UIImage(named: "upload"))
                
                communitycell.lblMemberName.text = mycommunity.username
                communitycell.lblMemberDetails.isHidden = true
                communitycell.lblHourAgo.isHidden = true
                //            storageref = FIRStorage.storage().reference(forURL: mycommunity.userimage!)
                //            self.storageref.data(withMaxSize: 10*1024*1024, completion: { (data, error) in
                //                let imagedata = data
                //                if imagedata != nil{
                //                    communitycell.imgUser.image = UIImage(data: imagedata!)
                //                }  })
            }
            else
            {
                
                communitycell.imgUser.image  = UIImage(named: "upload")
            }
            cell = communitycell
        }
        else
        {
            let commentcell: CommentsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "GroupChatCell") as! CommentsTableViewCell
    
            var groupChat = GroupMessage()
            groupChat = groupChatItems[indexPath.row]
            
            if let msgTxt:String = groupChat.messageText as? String
            {
                commentcell.commentText.text = msgTxt
            }
            
            if let msgUser:String = groupChat.messageUser
            {
                commentcell.username.text = msgUser
            }
            
            if let msgTime:String = groupChat.messageTime
            {
                commentcell.sendTime.text = msgTime
            }
            
            if let filepath:String = groupChat.messagePhotoUrl             {
                commentcell.userImage.sd_setImage(with: URL(string: filepath as! String), placeholderImage: UIImage(named: "upload"))
            }
            else
            {
                commentcell.userImage.image = UIImage(named: "upload")
            }
            
            cell = commentcell
            
        }
        return cell!
    }
    
    func getGroupChatData()
    {
        ref = FIRDatabase.database().reference()
        ref.child("GroupMessages").observe(.value, with:  { (snapshot) in
            
            var groupChatItems = [GroupMessage]()
            for id in snapshot.children
            {
                
                let data = snapshot.value as! Dictionary<String, Any>

                let groupMessage = GroupMessage(snapshot: id as! FIRDataSnapshot)
                groupChatItems.insert(groupMessage, at: 0)
                print(data)
            }
            self.groupChatItems = groupChatItems
            DispatchQueue.main.async(execute:
                {
                    self.GroupChatTable.reloadData()
                    Utilities.sharedInstance.hideHUD(view: self.view)
            })
        })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getcommunitydata()
    {
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
        var location = String()
        ref = FIRDatabase.database().reference()
        ref.child("User_Profiles").child(userID).observe(.value, with:  { (snapshot) in
            
            let value = snapshot.value as! Dictionary<String, Any>
          
            if   let newlocation = value["city"] as? String
            {
                print(newlocation)
                location = newlocation
            }else{
                location = "chennai"
            }
            self.getcommunitydatabycity(city: location)
            })
    }
    
    func getcommunitydatabycity(city: String)
    {
        ref = FIRDatabase.database().reference()
        self.ref.child("User_Profiles").queryOrdered(byChild: "city").queryEqual(toValue: city).observe(.value, with:  { (snapshot) in
            
            var communityitem = [Usersdetails]()
            for id in snapshot.children
            {
                let newshare = Usersdetails(snapshot: id as! FIRDataSnapshot)
                communityitem.insert(newshare, at: 0)
                print(communityitem)
            }
            self.communitydata = communityitem
            DispatchQueue.main.async(execute:{
                self.CommunityTable.reloadData()
            })
        })
        { (error) in
            print(error.localizedDescription)
        }
    }
}
