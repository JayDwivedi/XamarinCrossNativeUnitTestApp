//
//  requestFormViewController.swift
//  HereYaGo
//
//  Created by Dawn on 24/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

var postedusername = "username"
var postedusermobile = "mobile"
let senderuid = "uid"
var senderlocation = "location"
var requestedusername = "username"
var requestedusermobile = "mobile"
var requesteduserlocation = "location"
var receiveruid = "userid"

class requestFormViewController: UIViewController {
    @IBOutlet var productnamefield: UITextField!
    @IBOutlet var mobilefield: UITextField!
    @IBOutlet var locationfield: UITextField!
    @IBOutlet var fromdatefield: UITextField!
    @IBOutlet var todatefield: UITextField!
   
    @IBOutlet weak var productImageView: UIImageView!
    
    var productData: shareitem!
    var productid = String()
    var requestinfoDict:[String : String] = [:]
    var ref: FIRDatabaseReference!
    var storageREF : FIRStorageReference!
    let FromdatePicker:UIDatePicker = UIDatePicker()
    let TodatePicker:UIDatePicker = UIDatePicker()
    var username : String = "";
    var phoneNumber : String = "";
    var userProfileURL : String = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.displaycurrentUserdata()
        self.getsharedetailsfromdb()
        productnamefield.isUserInteractionEnabled = false;
        
        //  save username to current user
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)!
        
        storageREF = FIRStorage.storage().reference()
        ref.child("User_Profiles").child("\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value)
            let value = snapshot.value as? NSDictionary
            self.username = (value?["userName"] as? String)!
            self.mobilefield.text = (value?["userMobileNumber"] as? String)!
            self.userProfileURL =  (value?["userProfilePic"] as? String)!
           
            self.fromdatefield.textColor = UIColor.white
            self.todatefield.textColor = UIColor.white
            
            if let profileImg : String = self.productData.itemimage
            {
                let url:URL = URL(string: profileImg)!
                self.productImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "upload"))
            } else{
                self.productImageView.image = UIImage(named: "upload")
            }
            
        })
        {  (error) in
            print(error.localizedDescription)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func requestsendaction(_ sender: Any) {
        
        if validateData()
        {
        
        ref = FIRDatabase.database().reference()
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)!
            
        let requestinfoDict : Dictionary<String, Any> = ["productid": productData.key!,
                                                         "mobilenumber": mobilefield.text!,
                                                         "location": locationfield.text!,
                                                         "fromdate": fromdatefield.text!,
                                                         "todate": todatefield.text!,
                                                         "status": "send",
                                                         "name": self.username,
                                                         "senderuid": userID,
                                                         "postedname": self.username,
                                                         "profileimage": productData.itemimage!,
                                                         "userImg": self.userProfileURL
            
                                                         ]
        let requestDict : Dictionary<String, Any> = ["productid": productData.key!,
                                                         "mobilenumber": mobilefield.text!,
                                                         "location": locationfield.text!,
                                                         "fromdate": fromdatefield.text!,
                                                         "todate": todatefield.text!,
                                                         "status": "received",
                                                         "name": self.username,
                                                         "senderuid":(FIRAuth.auth()!.currentUser?.uid)!,
                                                         "userImg": self.userProfileURL,
                                                         "profileimage": productData.itemimage!
                                                         ]
        ref.child("User_Profiles").child((FIRAuth.auth()!.currentUser?.uid)!).child("Inbox").childByAutoId().setValue(requestinfoDict)
        
         ref.child("User_Profiles").child(receiveruid).child("Inbox").childByAutoId().setValue(requestDict)
        self.navigationController?.popViewController(animated: true)
        }
    }
    
    func validateData() -> Bool
    {
        var valid : Bool = true;
        
        if  (self.fromdatefield.text?.characters.count)! < 1
        {
            valid = false;
            Utilities.sharedInstance.showErrorMessage("Date should not be empty", message: "", controller: self)
            return valid;
        }
        
        if  (self.todatefield.text?.characters.count)! < 1
        {
            valid = false;
            Utilities.sharedInstance.showErrorMessage("Date should not be empty", message: "", controller: self)
            return valid;
        }
        
        return valid
    }
    
    
    @IBAction func Fromdatepicker(_ sender: UITextField) {
      //  let datePickerView:UIDatePicker = UIDatePicker()
        
        FromdatePicker.datePickerMode = UIDatePickerMode.date
        
        sender.inputView = FromdatePicker
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        fromdatefield!.text = dateFormatter.string(from: Date())
        
        FromdatePicker.addTarget(self, action: #selector(requestFormViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
        
    }
    @IBAction func Todatpicker(_ sender: UITextField) {
        TodatePicker.datePickerMode = UIDatePickerMode.date
        
        sender.inputView = TodatePicker
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        todatefield!.text = dateFormatter.string(from: Date())
        
        TodatePicker.addTarget(self, action: #selector(requestFormViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
        
    }
    func datePickerValueChanged(_ sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
      //  dateFormatter.timeStyle = DateFormatter.Style.medium
        if (sender == FromdatePicker){
            fromdatefield!.text = dateFormatter.string(from: sender.date)
        }
        if (sender == TodatePicker){
             todatefield!.text = dateFormatter.string(from: sender.date)
        }
    }


    @IBAction func cancelaction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    func getsharedetailsfromdb(){
        
        self.productnamefield.text = productData.itemtitle
        receiveruid = productData.userid!
        // No need of following code
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
       
        ref = FIRDatabase.database().reference()
        storageREF = FIRStorage.storage().reference()
        ref.child("Share").child("sharesall").child(productData.key).child(productData.userid!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value)
            let value = snapshot.value as? NSDictionary
            if  value != nil
            {
                self.productnamefield.text = value?["title"] as? String
                //  self.productdes.text = value?["strDescription"] as! String?
                receiveruid = (value?["uid"] as! String?)!
                self.displayUserdata(userid: receiveruid)
            }
             })
        {  (error) in
            print(error.localizedDescription)
        }
       // */
    }
    
    func displayUserdata(userid: String){
        let userID = userid
        ref = FIRDatabase.database().reference()
        storageREF = FIRStorage.storage().reference()
        ref.child("User_Profiles").child("\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value)
            let value = snapshot.value as? NSDictionary
            postedusername = (value?["userName"] as? String)!
            postedusermobile = (value?["userMobileNumber"] as? String)!
        
            })
            {  (error) in
            print(error.localizedDescription)
        }
    }
    
    func displaycurrentUserdata()
    {
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
        ref = FIRDatabase.database().reference()
        storageREF = FIRStorage.storage().reference();
                FIRAuth.auth()?.addStateDidChangeListener() { auth, user in

            if user != nil {
                
                print(user ?? "user is nil")

            } else {
                print("Not signed in")
            }
        }
////        ref.child("User_Profiles").child((FIRAuth.auth()?.currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value)
//            let value = snapshot.value as? NSDictionary
//            requestedusername = (value?["userName"] as? String)!
//            requestedusermobile = (value?["userMobileNumber"] as? String)!
//            senderlocation = (value?["city"] as? String)!
//            self.locationfield.text = senderlocation
//            self.mobilefield.text = requestedusermobile
//        
//        })
//        {  (error) in
//            print(error.localizedDescription)
//        }
        
    }



}
