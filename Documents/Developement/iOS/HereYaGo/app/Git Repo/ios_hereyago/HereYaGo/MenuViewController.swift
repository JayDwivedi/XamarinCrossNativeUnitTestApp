//
//  MenuViewController.swift
//  HereYaGo
//
//  Created by DawnShine on 15/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class MenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{

    var badgescount : Int!
    var rankCount : Int!
    
    var ref = FIRDatabaseReference()
    var storageref = FIRStorageReference()
    @IBOutlet var menuTable: UITableView!
    
    @IBOutlet var profiledetails: UILabel!
    @IBOutlet var profileimage: UIImageView!
    @IBOutlet var profilename: UILabel!
    
    @IBOutlet weak var notificationCountLabel: UILabel!
    
    var sections: [Sections] = MenuSectionsData().getSectionsFromData()
    
    func setNotificationCount()
    {
        var inboxdata = [Inboxitem]()
        ref = FIRDatabase.database().reference()
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
        ref.child("User_Profiles").child(userID).child("Inbox").observe(.value, with:  { (snapshot) in
            
            var inbox = [Inboxitem]()
            for id in snapshot.children
            {
                let newshare = Inboxitem(snapshot: id as! FIRDataSnapshot)
                inbox.insert(newshare, at: 0)
                print(inbox)
            }
            inboxdata = inbox
            self.notificationCountLabel.text = "\(inboxdata.count)"
        })
        { (error) in
            print(error.localizedDescription)
            self.notificationCountLabel.text = "0"
        }
    }
    
    func getRankCount()
    {
        self.ref = FIRDatabase.database().reference()
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)!
        let query = self.ref.child("User_Profiles").queryOrdered(byChild: "id").queryEqual(toValue:userID)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let snap: FIRDataSnapshot? = snapshot else {
                print("No Reuslt Found")
                return
            }
            if snap?.value is NSNull
            {
                print("user not available")
            }
            else
            {
                let dict:Dictionary = snap?.value as! [String : AnyObject]
                let userId = Array(dict.keys)[0]
                let userInfo =  dict[userId]
                self.profilename.text = userInfo!["userName"]! as? String
                let rnk:String = (userInfo!["rank"] as? String)!
                self.rankCount = Int(rnk)
                
                if self.rankCount != nil && self.badgescount != nil
                {
                    self.profiledetails.text = "Badges:\(self.badgescount!),Rank : \(self.rankCount!)"
                }
                
                if let profileImg : String = userInfo?["userProfilePic"] as? String
                {
                    let url:URL = URL(string: profileImg)!
                    self.profileimage.sd_setImage(with: url, placeholderImage: UIImage(named: "upload"))
                } else{
                    self.profileimage.image = UIImage(named: "upload")
                }
            }
        })
    }
    
    func getbadgescount()
    {
        var count = Int()
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String

        ref = FIRDatabase.database().reference()
        ref.child("User_Profiles").child(userID).child("Badges").observe(.value, with:  { (snapshot) in
            print(snapshot.childrenCount)
            
            self.badgescount  = Int(snapshot.childrenCount)
            self.getRankCount()
        })
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.getbadgescount()
        self.setNotificationCount()
        self.notificationCountLabel.layer.cornerRadius = self.notificationCountLabel.frame.size.height/2
        self.displayUserdata()
        self.profileimage.clipsToBounds = true
        self.profileimage.layer.cornerRadius = self.profileimage.frame.size.width/2
        self.profileimage.backgroundColor = UIColor.red
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
            self.getbadgescount()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func acionLogout(_ sender: Any)
    {
        UserDefaults.standard.set(false, forKey: Constant.isLoginSuccessFully)
        UserDefaults.standard.set(false, forKey: Constant.UserDefaultEmail)
        UserDefaults.standard.set(false, forKey: Constant.UserDefaultUserId)
        UserDefaults.standard.set(false, forKey: Constant.UserDefaultEmail)
        UserDefaults.standard.set(false, forKey: Constant.UserDefaultUserName)
        UserDefaults.standard.synchronize()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : MenuCell = tableView.dequeueReusableCell(withIdentifier: "menucells", for: indexPath) as! MenuCell
        cell.lblMenuname.text = sections[indexPath.section].menuItems[indexPath.row]
        let imageName = sections[indexPath.section].menuImages[indexPath.row]
        cell.imgMenu.image = UIImage(named: imageName)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell : MenuCell = menuTable.cellForRow(at: indexPath) as! MenuCell
        cell.selectionStyle = .gray
        print(sections[indexPath.section].menuItems[indexPath.row])
        if indexPath.section == 0
        {
            switch indexPath.row
            {
            case 0:
                self.performSegue(withIdentifier: "GoToTimeLine", sender: self)
                break;//GoToProfile
            case 1:
                self.performSegue(withIdentifier: "GoToProfile", sender: self)
                break;
            case 2:
                print("TheBigPicture")
                self.performSegue(withIdentifier: "GoToBigPicture", sender: self)
                break;
            case 3:
                print("Community")
                self.performSegue(withIdentifier: "GoToCommunity", sender: self)
                break;
            case 4:
                print("Leaderboard")
                self.performSegue(withIdentifier: "GoToLeaderboard", sender: self)
                break;
            case 5:
                print("Gift")
                self.performSegue(withIdentifier: "GoToGiftViewController", sender: self)
                break;
            case 6:
                print("How to share")
                var youtubeUrl:URL = NSURL(string:"https://youtu.be/gAPLItJYaYE")! as URL
                if UIApplication.shared.canOpenURL(youtubeUrl as URL)
                {
                    UIApplication.shared.openURL(youtubeUrl)
                } else{
                    youtubeUrl = NSURL(string:"https://youtu.be/gAPLItJYaYE")! as URL
                    UIApplication.shared.openURL(youtubeUrl);
                }
                //self.performSegue(withIdentifier: "GoToHowToShare", sender: self)
                break;
            case 7:
                print("Setting")
                self.performSegue(withIdentifier: "GoToSetting", sender: self)
                break;
            default:
                self.performSegue(withIdentifier: "GoToTimeLine", sender: self)
                print("Default Statement")
                break;
            }
        }
    }
    
    @IBAction func sharenowaction(_ sender: Any)
    {
      //  self.navigationController?.navigationBar.isHidden = true;
        self.performSegue(withIdentifier: "sharenowsegue", sender: self)
    }
    @IBAction func inboxaction(_ sender: Any) {
        self.performSegue(withIdentifier: "GotoInbox", sender: self)
    }
    
    func displayUserdata()
    {
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)!
        ref = FIRDatabase.database().reference()
        storageref = FIRStorage.storage().reference()
        ref.child("User_Profiles").child(userID as! String).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value)
            let value = snapshot.value as? NSDictionary
            self.profilename.text = value?["userName"] as? String
            if snapshot.hasChild("userProfilePic"){
                let filepath = value?["userProfilePic"]
                if filepath != nil {
                    
                    self.profileimage.sd_setImage(with: URL(string: filepath as! String), placeholderImage: UIImage(named: "upload"))
                    
//                    FIRStorage.storage().reference(forURL: filepath as! String).data(withMaxSize: 10*1024*1024, completion: { (data, error) in
//                        let imagedata = data
//                        if imagedata != nil{
//                      // if   let userPhoto = UIImage(data: (data)!){
//                            self.profileimage.image = UIImage(data: imagedata!)
//                        }else {
//                            self.profileimage.image = UIImage(named: "upload")
//                        }
//                        
//                    })
                    var userdetailsdefaults = UserDefaults.standard.set(value?["userName"], forKey: "username")
                    userdetailsdefaults = UserDefaults.standard.set(filepath, forKey: "userimage")
                }else{
                    self.profileimage.image = UIImage(named: "upload")
                }}
        })
        {  (error) in
            print(error.localizedDescription)
        }
        
    }

}
