//
//  ShareformViewController.swift
//  HereYaGo
//
//  Created by Dawn on 18/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class ShareformViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate,UITextFieldDelegate {
    
    var isFromTimeLine:Bool = false
    @IBOutlet var titleofshare: UITextField!
    @IBOutlet var descriptionofshare: UITextView!
    @IBOutlet var DaysofShare: UITextField!
    @IBOutlet var dateofShare: UITextField!
    @IBOutlet var imageofshare: UIImageView!
    @IBOutlet var categoryofshare: UITextField!
    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet var sharebutton: UIBarButtonItem!


    var ref: FIRDatabaseReference!
    var storage: FIRStorageReference!
    var previewDict:[String : String] = [:]
    var categoryPickerView = UIPickerView()
      let myPickerData = [String](arrayLiteral: "Automative", "BabyProducts", "Beauty","Electronics", "Fitness", "Furniture","Games","Gardening","KidFriendly","Lighting","SportsEquipments","Tools")
    let pointArray = [Int] (arrayLiteral: 100, 120,140,150,110,120,125,130,110,100,100)
    var selectedIndex : Int = 0;
    var points : Int = 0;

    override func viewDidLoad()
    {
        super.viewDidLoad()
        if revealViewController() != nil {
            //            revealViewController().rearViewRevealWidth = 62
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            self.navigationController?.navigationBar.isHidden = true
            revealViewController().rightViewRevealWidth = 150
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
            Utilities.sharedInstance.hideHUD(view: self.view)
        }
        
        if previewDict != nil
        {
            titleofshare.text = previewDict[ktitle]
            descriptionofshare.text = previewDict[kdescription]
            categoryofshare.text = previewDict[kcategory]
        }
        self.categoryPickerView.delegate = self
        self.categoryofshare.inputView = categoryPickerView
        categoryPickerView.selectRow(2, inComponent:0, animated:true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func uploadimagebtntapped(_ sender: Any) {
      //  self.handleSelectProfileImageView()
        self.topsharebtnshared()
    }
    
    @IBAction func menubuttontapped(_ sender: Any)
    {
        if revealViewController() != nil
        {
            // revealViewController().rearViewRevealWidth = 62
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rightViewRevealWidth = 150
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    
    //topsharebtn tapped:
    
    func  topsharebtnshared()
    {
        let actionSheetController : UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "cancel button"), style: .cancel) { void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let cameraAction: UIAlertAction = UIAlertAction(title: "Camera", style: .default)
        { void in
            self.camera()
            // self.handleSelectProfileImageView()
        }
        actionSheetController.addAction(cameraAction)
        
        let Photolipraryaction: UIAlertAction = UIAlertAction(title: "Photo Library", style: .default)
        { void in
            self.photoLibrary()
            
            print("Delete")
        }
        actionSheetController.addAction(Photolipraryaction)
        self.present(actionSheetController, animated: true, completion: nil)
       // self.performSegue(withIdentifier: "GotoShareformfromTopShare", sender: self)
    }
    
    func camera()
    {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.camera
        self.present(myPickerController, animated: true, completion: nil)
    }
    
    func photoLibrary()
    {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(myPickerController, animated: true, completion: nil)
    }

    func handleSelectProfileImageView()
    {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
        {
            print("Button capture")
            let picker = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let selectedimage = info[UIImagePickerControllerOriginalImage]
        self.imageofshare.image = selectedimage as! UIImage?
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textFieldEditing(_ sender: UITextField)
    {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(ShareformViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
    }
    
    func datePickerValueChanged(_ sender:UIDatePicker)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.medium
        dateofShare!.text = dateFormatter.string(from: sender.date)
    }
    
    // MARK:- PICKER VIEW
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        return 25;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // TODO: Replace with data count
        return myPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // TODO: Replace with proper data
        selectedIndex = row;
        return myPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryofshare.text = myPickerData[row]
    }
    
    // MARK:- TextField delegate 
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == categoryofshare
        {
            categoryofshare.text = myPickerData[2]
        }
        return true
    }

    @IBAction func shareactiontapped(_ sender: Any)
    {
             if validateData()
             {
                  self.addingpoints()
                 //self.addingpoints1()
                
                Utilities.sharedInstance.showHUD(view: self.view)
                let dateFormatter1 = DateFormatter()
                dateFormatter1.dateStyle = .medium
                dateFormatter1.dateFormat = "dd-MM-yyyy"
                let date = dateFormatter1.string(from: NSDate() as Date)
                let timeFormatter = DateFormatter()
                timeFormatter.timeStyle = .medium
                timeFormatter.dateFormat = "hh:mm:ss a"
                let time = timeFormatter.string(from: Date() as Date)
                ref = FIRDatabase.database().reference()
                let storage = FIRStorage.storage().reference()
                var data = NSData()
                data = UIImageJPEGRepresentation(imageofshare.image!, 0.8)! as NSData
                let metaData = FIRStorageMetadata()
                metaData.contentType = "image/jpeg"
                let filePath = "\("Shares")/\(NSDate().timeIntervalSince1970)"
                
                self.ref = FIRDatabase.database().reference()
                let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)!                
                let query = self.ref.child("User_Profiles").queryOrdered(byChild: "id").queryEqual(toValue:userID)
                var userName : String = "Invalid user";
                var userProfileUrl : String = "";
                
                query.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard let snap: FIRDataSnapshot? = snapshot else {
                        print("No Reuslt Found")
                        Utilities.sharedInstance.hideHUD(view: self.view)
                        return
                    }
                    if snap?.value is NSNull
                    {
                        print("user not available")
                        Utilities.sharedInstance.hideHUD(view: self.view)
                    }
                    else
                    {
                        let dict:Dictionary = snap?.value as! [String : AnyObject]
                        let userId = Array(dict.keys)[0]
                        let userInfo =  dict[userId]
                        userName =  (userInfo!["userName"]! as? String)!
                        userProfileUrl = userInfo?["userProfilePic"] as! String
                    }
                    
                    storage.child(filePath).put(data as Data, metadata: metaData){(metaData,error) in
                        
                        if let error = error
                        {
                            print(error.localizedDescription)
                            return
                        }else
                        {
                            //store downloadURL
                            let downloadURL = metaData!.downloadURL()!.absoluteString
                            let shareinfo : Dictionary<String, Any> = ["title": self.titleofshare.text! as String,
                                                                       "strDescription": self.descriptionofshare.text! as String,
                                                                       "category": self.categoryofshare.text! as String,
                                                                       "imgUrl" : downloadURL,
                                                                       "date": "\(date)",
                                
                                "uid": (FIRAuth.auth()!.currentUser?.uid)!,
                                "numDays": self.DaysofShare.text ?? 0,
                                "userName": userName,
                                "likesCount": 0,
                                "commentsCount":0,
                                "userProfileIcon":userProfileUrl,
                                "Points": self.points
                               // "rank" : "0"
                            ]
                            self.ref.child("User_Profiles").child((FIRAuth.auth()!.currentUser?.uid)!).child("Myshares").childByAutoId().setValue(shareinfo)
                            self.ref.child("Share").child("sharesall").childByAutoId().setValue(shareinfo)
                            self.addingBadges()
                          //  self.addingpoints()
                            Utilities.sharedInstance.hideHUD(view: self.view)
                            
                            let selectedController : UINavigationController = (self.storyboard?.instantiateViewController(withIdentifier: "nav"))! as! UINavigationController
                            self.revealViewController().setFront(selectedController, animated: true)
                        }
                    }
                })
        }
        
    }
    
    
    func validateData() -> Bool
    {
        var valid : Bool = true;
        
        if  (titleofshare.text?.characters.count)! < 1
        {
            valid = false;
            Utilities.sharedInstance.showErrorMessage("Title of share should not be empty", message: "", controller: self)
            return valid;
        }
        
        if  (descriptionofshare.text?.characters.count)! < 1
        {
            valid = false;
            Utilities.sharedInstance.showErrorMessage("Share description should not be empty", message: "", controller: self)
            return valid;
        }
        if  ((categoryofshare.text?.characters.count))! < 1
        {
            valid = false;
            Utilities.sharedInstance.showErrorMessage("Category should not be empty", message: "", controller: self)
            return valid;

        }
        if  (dateofShare.text?.characters.count)! < 5
        {
            valid = false;
            Utilities.sharedInstance.showErrorMessage("Share date should not be empty", message: "", controller: self)
            return valid;
        }
        
        if  (DaysofShare.text?.characters.count)! < 1
        {
            valid = false;
            Utilities.sharedInstance.showErrorMessage("Days of share should not be empty", message: "", controller: self)
            return valid;
        }
        var isSelectImage = image(image1: imageofshare.image!, isEqualTo: UIImage.init(named: "login-bg")!)
        
        if(isSelectImage == true)
        {
            valid = false;
            Utilities.sharedInstance.showErrorMessage("Share image should not be empty.", message: "", controller: self)
            return valid;
        }
        
        
        return valid
    }
   
    
    func image(image1: UIImage, isEqualTo image2: UIImage) -> Bool {
        let data1: NSData = UIImagePNGRepresentation(image1)! as NSData
        let data2: NSData = UIImagePNGRepresentation(image2)! as NSData
        return data1.isEqual(data2)
    }
    
    func addingpoints()
    {
        ref = FIRDatabase.database().reference()
        self.ref.child("CategoriesPoints").child(self.categoryofshare.text!).observeSingleEvent(of: .value, with: {(snapshot) in
            
            var pointvalue : Int = 0;
            if let pointvalue1 : Int = (snapshot.value as? Int)
            {
                pointvalue = pointvalue1;
            }
            self.ref.child("User_Profiles").child((FIRAuth.auth()!.currentUser?.uid)!).child("Points").runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
                var value = currentData.value as? Int
                if value == nil
                {
                    value = 0
                }
                //currentpointvalue = currentpointvalue! + pointvalue
               // currentData.value = (value! + pointvalue)
                currentData.value = (value! + self.pointArray[self.selectedIndex]
                )
                print(currentData.value!)
               self.points = currentData.value as! Int;
                return FIRTransactionResult.success(withValue: currentData)})
        })
    }
    
    func addingpoints1()
    {
        ref = FIRDatabase.database().reference()
        self.ref.child("CategoriesPoints").child(self.categoryofshare.text!).observeSingleEvent(of: .value, with: {(snapshot) in
            
            var pointvalue : Int = 0;
            if let pointvalue1 : Int = (snapshot.value as? Int)
            {
                pointvalue = pointvalue1;
            }
            self.ref.child("Share").child("sharesall").child((FIRAuth.auth()!.currentUser?.uid)!).child("Points").runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            var value = currentData.value as? Int
            if value == nil
            {
                value = 0
            }
            //currentpointvalue = currentpointvalue! + pointvalue
            // currentData.value = (value! + pointvalue)
            currentData.value = (value! + self.pointArray[self.selectedIndex]
            )
             return FIRTransactionResult.success(withValue: currentData)})
        })
    }
    
    func addingBadges()
    {
            ref = FIRDatabase.database().reference()
        self.ref.child("User_Profiles").child((FIRAuth.auth()!.currentUser?.uid)!).child("Badges").observe(.value, with: {(snapshot) in
            
            if snapshot.hasChild(self.categoryofshare.text!){
                print("Has Badge")
            }else{
                let badgeinfo : Dictionary<String, Any> = [self.categoryofshare.text! : "true"]
                self.ref.child("User_Profiles").child((FIRAuth.auth()!.currentUser?.uid)!).child("Badges").child(self.categoryofshare.text!).setValue(self.categoryofshare.text!)
            }
        })
    }
    
    @IBAction func backbuttonpressed(_ sender: Any)
    {
         self.navigationController?.popViewController(animated: true)
    }
}
