//
//  SignUpViewControllerCategory.swift
//  HereYaGo
//
//  Created by DawnShine on 15/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class SignUpViewControllerCategory: BaseViewController, UITableViewDataSource,UITableViewDelegate {
    
    var isFromSocial:Bool = false
    @IBOutlet var signupCategoryTable: UITableView!
    var previewDict:[String : String] = [:]
    var ref: FIRDatabaseReference!
    var randomdigit: String!
    var selectedCategoryData : [String] = []
    let categoryData : [String] = ["Furniture","Kitchen","Electronics","Electrical","Household","Fashion","Decor","Bady","Garden","Office"]
    override func viewDidLoad() {
        super.viewDidLoad()
         self.signupCategoryTable.allowsMultipleSelection = true
         ref = FIRDatabase.database().reference()
         randomdigit = self.generateRandomDigits(4)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : SignUpCategoryCell = signupCategoryTable.dequeueReusableCell(withIdentifier: "category", for: indexPath) as! SignUpCategoryCell
        cell.lblCategory.text = categoryData[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell : SignUpCategoryCell = signupCategoryTable.cellForRow(at: indexPath) as! SignUpCategoryCell
        cell.selectionStyle = .none
        cell.imgCheck.image = UIImage(named: "tick")
        selectedCategoryData.append(categoryData[indexPath.row])
        print(categoryData[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        let cell : SignUpCategoryCell = signupCategoryTable.cellForRow(at: indexPath) as! SignUpCategoryCell
        cell.selectionStyle = .none
        cell.imgCheck.image = UIImage(named: "")
    }
    
    @IBAction func btnPrevious(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
         //self.performSegue(withIdentifier: "SignUpAddress", sender: self)
    }
    
    @IBAction func btnNext(_ sender: Any)
    {
        Utilities.sharedInstance.showHUD(view: self.view)
        self.signupvaalid()
    }
    
    func generateRandomDigits(_ digitNumber: Int) -> String {
        var number = ""
        for i in 0..<digitNumber {
            var randomNumber = arc4random_uniform(10)
            while randomNumber == 0 && i == 0 {
                randomNumber = arc4random_uniform(10)
            }
            number += "\(randomNumber)"
        }
        return number
    }
    
    func signupvaalid()
    {
        let email = previewDict[Kmailid]
        let password = previewDict[Kpassword]
        
        ref = FIRDatabase.database().reference()
        
        if isFromSocial == true
        {
            self.adduser()
        }
        else
        {
        
        FIRAuth.auth()?.createUser(withEmail: email!, password: password!, completion: { (user, error) in
            if let error = error {
                
                Utilities.sharedInstance.hideHUD(view: self.view)
                if let errCode = FIRAuthErrorCode(rawValue: error._code) {
                    switch errCode
                    {
                    case .errorCodeInvalidEmail:
                        self.showAlertView(withTitle: "Enter a valid email.")
                    case .errorCodeEmailAlreadyInUse:
                        self.showAlertView(withTitle: "Email already in use.")
                    default:
                        self.showAlertView(withTitle: "Error: \(error.localizedDescription)")
                    }
                }
                return
            }
            else
            {
                self.adduser()
            }
        })
        }
    }
    
    func adduser()
    {
        ref = FIRDatabase.database().reference()
        
        var categoryDict:[String:AnyObject] = [:]
        if selectedCategoryData.count > 0
        {
            for position in 0...selectedCategoryData.count-1
            {
                categoryDict.updateValue(true as AnyObject, forKey: selectedCategoryData[position])
            }
        }
        
     //   let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
        var userinfo : Dictionary<String, Any> = ["userName": previewDict[KuserName]!,
                                                  "userNickName": previewDict[KnickName]!,
                                                  "userEmail": previewDict[Kmailid]!,
                                                  "id": (FIRAuth.auth()?.currentUser?.uid)!,
                                                  "Points": 0,
                                                  "userMobileNumber": previewDict[Kusermobile]!,
                                                  "userCategory":categoryDict,
                                                  "houseNumber": previewDict[Kuserdoorno]!,
                                                  "street": previewDict[Kuserstreet]!,
                                                  "city": previewDict[Kusercity]!,
                                                  "state": previewDict[Kuserstate]!,
                                                  "country": previewDict[Kusercountry]!,
                                                  "zipCode": previewDict[KuserZip]!,
                                                  "otp": randomdigit,
                                                  "rank":"0",
                                                  "latitude": previewDict[Klattitute]!,
                                                  "longitude": previewDict[Klongitute]!,
                                                  "status":"Not_Activated"
                                                   ]
        
        if ( isFromSocial == false )
        {
            userinfo.updateValue(previewDict[Kpassword]!, forKey: "userPassword")
        }
        
        if ( isFromSocial == true)
        {
            userinfo.updateValue(previewDict["profilePic"]!, forKey: "userProfilePic")
        }
        
        ref.child("User_Profiles").child((FIRAuth.auth()!.currentUser?.uid)!).setValue(userinfo,withCompletionBlock: {
            (error, snapshot) in
            
            let storage = FIRStorage.storage().reference()
            
            if ( self.isFromSocial == false)
            {
                var data = NSData()
                if let d : NSData  = UserDefaults.standard.object(forKey: Kuserimage) as? NSData
                {
                    data = UserDefaults.standard.object(forKey: Kuserimage) as! NSData
                }
                // data = UIImageJPEGRepresentation(, 0.8)! as NSData
                let metaData = FIRStorageMetadata()
                metaData.contentType = "image/jpeg"
                let filePath = "\("User_Profiles")/\(NSDate().timeIntervalSince1970)"
                storage.child(filePath).put(data as Data, metadata: metaData){(metaData,error) in
                    
                    if let error = error
                    {
                        Utilities.sharedInstance.hideHUD(view: self.view)
                        print(error.localizedDescription)
                        return
                    }else{
                        //store downloadURL
                        let downloadURL = metaData!.downloadURL()!.absoluteString
                        //store downloadURL at database
                        self.ref.child("User_Profiles").child((FIRAuth.auth()!.currentUser?.uid)!).updateChildValues(["userProfilePic": downloadURL])
                        self.requestforactivation(emailstring: self.previewDict[Kmailid]!)
                        Utilities.sharedInstance.hideHUD(view: self.view)
                        self.signIn()
                    }
                }
            }
            else
            {
                Utilities.sharedInstance.hideHUD(view: self.view)
                self.requestforactivation(emailstring: self.previewDict[Kmailid]!)
                self.signIn()
            }
        })
        
      //TODO : not need to request for actvation
      //self.showAlertView(withTitle: "Please Check Your Mail four your Account Activation")
    }
    
    func requestforactivation(emailstring: String)
    {
        _ = ["emailid": emailstring] as Dictionary<String, String>
        let urlString = String(format: "http://itideology.com/hereyago-dev/webapi/?emailid=%@&code=%@",emailstring,randomdigit)        //create the url with URL
        let url = URL(string: urlString)! //change the url
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = emailstring.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
             }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
            Utilities.sharedInstance.hideHUD(view: self.view)
        }
        task.resume()
    }
    
    func signIn()
    {
        Utilities.sharedInstance.hideHUD(view: self.view)
       // self.performSegue(withIdentifier: "GotoActivationFromSignup", sender: self)
         let activationVC = self.storyboard?.instantiateViewController(withIdentifier: "ActivationViewController") as! ActivationViewController
            activationVC.userEmail = self.previewDict[Kmailid]!
          activationVC.isFromLoginVC = false
          self.navigationController?.pushViewController(activationVC, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GotoActivationFromSignup"{
        
            let _ : ActivationViewController =  segue.destination as! ActivationViewController
            
            
            // let vc = self.storyboard?.instantiateViewController(withIdentifier: "TimeLineViewController") as! TimeLineViewController
            //vc.defaultdata = data
            //  self.navigationController?.pushViewController(vc, animated: true)
        
        }
        
    }

}
