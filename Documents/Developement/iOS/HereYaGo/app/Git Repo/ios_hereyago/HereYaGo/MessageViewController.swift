//
//  MessageViewController.swift
//  HereYaGo
//
//  Created by Dawn on 25/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

var Status : String = "send"
var requestuserid : String = "userid"
var acceptusername : String = "userid"
var acceptusermobile: String = "mobile"
var acceptuserlocation: String = "location"
var productId: String = "prodcutId"
var productImageUrl: String = "productImageUrl"

class MessageViewController: UIViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet var displaytitle: UILabel!
   // @IBOutlet var requestedUserName: UILabel!
    @IBOutlet var requestedUserMobile: UILabel!
    @IBOutlet var requestedUserLocation: UILabel!
    @IBOutlet var requestedFromDate: UILabel!
    @IBOutlet var requestedToDate: UILabel!
    @IBOutlet weak var imaageViewForShareImage: UIImageView!
    @IBOutlet var acceptButton: UIButton!
    
    @IBOutlet weak var statusLabel: UILabel!
    var profileUrl : String = ""
    
    @IBOutlet weak var imgProfilePic: UIImageView!
    var ref = FIRDatabaseReference()
    var storageref = FIRStorageReference()
    var PathString = String()
    var requestedUserName : String = "";
    
    @IBOutlet weak var lblBadges: UILabel!
    @IBOutlet weak var lblRank: UILabel!

    @IBOutlet weak var lblMobileNumber: UILabel!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.imgProfilePic.layer.cornerRadius = self.imgProfilePic.frame.size.width/2
        Utilities.sharedInstance.showHUD(view: self.view)
        self.GetcurrentUserdata()
        self.acceptButton.isHidden = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func Acceptedaction(_ sender: UIButton)
    {
        
        self.navigationController?.popViewController(animated: true)
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
        ref = FIRDatabase.database().reference()
        let acceptedinfo : Dictionary<String, Any> = ["productid":productId,
                                                      "name": acceptusername,
                                                      "mobilenumber": acceptusermobile,
                                                      "location": acceptuserlocation,
                                                      "fromdate": self.requestedFromDate.text!,
                                                      "todate": self.requestedToDate.text!,
                                                      "senderuid":userID,
                                                      "userImg": profileUrl,
                                                      "status": "accepted",
                                                       "profileimage":  productImageUrl
                                                      ]
        let shippinginfo: Dictionary<String, Any>  = ["acceptuserid": userID,
                                                      "productid":productId,
                                                      "requestuseruid": requestuserid,
                                                      "requestname": self.requestedUserName,
                                                    //  "requestmobilenumber": self.requestedUserMobile.text!,
                                                      "requestlocation": self.requestedUserLocation.text!,
                                                      "fromdate": self.requestedFromDate.text!,
                                                      "todate": self.requestedToDate.text!,
                                                      "status": "Ready for shipping"]
        
     
      ref.child("User_Profiles").child(userID).child("Inbox").child(PathString).setValue(acceptedinfo);
        
      //  ref.child("User_Profiles").child(userID).child("Inbox").childByAutoId().setValue(acceptedinfo)
           ref.child("Shipping").childByAutoId().setValue(shippinginfo)

    }

    func Displaydate()
    {
        Utilities.sharedInstance.hideHUD(view: self.view)
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
        ref = FIRDatabase.database().reference()
        storageref = FIRStorage.storage().reference()
        
        ref.child("User_Profiles").child(userID).child("Inbox").child(PathString).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value)
            let value = snapshot.value as? NSDictionary
            //   self.displaytitle.text = value?["productid"] as? String
            self.requestedUserName = (value?["name"] as? String)!
            self.requestedUserMobile.text = value?["mobilenumber"] as? String
            print(self.requestedUserMobile)
            self.requestedUserLocation.text = value?["location"] as? String
            self.requestedFromDate.text = value?["fromdate"] as? String
            self.requestedToDate.text = value?["todate"] as? String
            requestuserid = value?["senderuid"] as! String
            productId = (value?["productid"] as? String)!
            
            // Status
            if let statusLocal:String = value?["status"]! as? String
            {
                Status = statusLocal
                self.statusLabel.text = statusLocal
            }
            else
            {
                self.statusLabel.text = Status
            }
            
            // Mobile number
            if let mobileNumberLocal:String = value?["mobilenumber"]! as? String
            {
                acceptusermobile = mobileNumberLocal
                self.lblMobileNumber.text = mobileNumberLocal
            }
            else
            {
                self.lblMobileNumber.text = "- Not Available"
            }
            
            if let userPic:String = value?["userImg"] as? String
            {
                self.imgProfilePic.sd_setImage(with: URL(string: userPic), placeholderImage: UIImage(named: "upload"))
                self.profileUrl = userPic;
            }
            
            if let imgURl:String = value?["profileimage"] as? String
            {
                self.imaageViewForShareImage.sd_setImage(with: URL(string: imgURl), placeholderImage: UIImage(named:"upload"))
                productImageUrl = imgURl;
            }
            
            self.buttondisplay(status: Status)
        })
        {  (error) in
            print(error.localizedDescription)
            Utilities.sharedInstance.hideHUD(view: self.view)
        }
    }
    func GetcurrentUserdata()
    {
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
        
        ref = FIRDatabase.database().reference()
        ref.child("User_Profiles").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
    
            let value = snapshot.value as? NSDictionary
           acceptusername = (value?["userName"] as? String)!
            acceptuserlocation = (value?["city"] as? String)!
            acceptusermobile = (value?["userMobileNumber"] as? String)!
            self.userNameLabel.text = acceptusername;
            var arr = [Any]()
            if let arrNew = value?["MyBadges"]
            {
                arr = [arrNew]
            }
            
            // if arr != nil
            self.lblBadges.text = "Badges : \(arr.count)"
        
            var rankCount : Int!
            let rnk:String = (value!["rank"] as? String)!
            rankCount = Int(rnk)
            if rankCount != nil
            {
                self.lblRank.text = "Rank : \(rankCount!)"
            }
            
//            if let userPic:String = value?["userProfilePic"] as? String
//            {
//                self.imgProfilePic.sd_setImage(with: URL(string: userPic), placeholderImage: UIImage(named: "upload"))
//            }
//            
//
            self.Displaydate()
        })
        {  (error) in
            
            self.Displaydate()
            print(error.localizedDescription)
        }
    }
    
    func buttondisplay(status: String)
    {
        print(status)
        if status == "received"
        {
            self.acceptButton.isHidden = false
        }
        else
        {
            self.acceptButton.isHidden = true
        }
    }

}
