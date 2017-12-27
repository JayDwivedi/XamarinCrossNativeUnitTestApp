//
//  ActivationViewController.swift
//  HereYaGo
//
//  Created by Dawn on 29/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class ActivationViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet var ACodeField: UITextField!
    var ref = FIRDatabaseReference()
    var userID: String = "nil"
    var statuscode: String = "nil"
    var userEmail = String()
    var isFromLoginVC : Bool = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ACodeField.delegate = self
        ACodeField.keyboardType = .numberPad
        self.btnBack.layer.cornerRadius = 5.0
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userLookUpByEmail (email: String, completionHandler: @escaping (_ result: String) -> Void)
    {
        ref = FIRDatabase.database().reference()
        
        ref.child("User_Profiles").queryOrdered(byChild: "userEmail").queryEqual(toValue: email).observeSingleEvent(of: .childAdded, with: { snapshot in
            if snapshot.value != nil {
                print(snapshot.key)
                self.userID = snapshot.key
            }
            else {
                print ("user not found")
                self.userID = "nil"
            }
            completionHandler(self.userID)
        })
    }
    
    @IBAction func submitbuttonAction(_ sender: Any)
    {
        ref = FIRDatabase.database().reference()
        self.userLookUpByEmail(email: userEmail)
        {
            (result: String) in
            print("\(result)")
        }
        
        let query = ref.child("User_Profiles").queryOrdered(byChild: "userEmail").queryEqual(toValue: userEmail)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let snap: FIRDataSnapshot? = snapshot else {
                print("No Reuslt Found")
                return
            }
            if snap?.value is NSNull
            {
                self.showAlertView(withTitle: "User Not registered")
            }
            else
            {
                let dict:Dictionary = snap?.value as! [String : AnyObject]
                let userId = Array(dict.keys)[0]
                let userInfo =  dict[userId]
                self.statuscode = userInfo!["otp"]! as! String
                print(self.statuscode)
                self.submitwithstatuscode()
            }
        })
        //self.submitStatusCode()
    }
    
    @IBAction func actionBackButton(_ sender: Any)
    {
        if ( isFromLoginVC )
        {
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    func submitStatusCode()
    {
        //create the url with URL
        let urlString = String(format: "http://itideology.com/hereyago-dev/webapi/?emailid=%@&code=%@",userEmail,ACodeField.text!)
        
        let url = URL(string: urlString)! //change the url
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // request.httpBody = statusCode.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
    }
    
    func setUserData()
    {
        let query = ref.child("User_Profiles").queryOrdered(byChild: "id").queryEqual(toValue: self.userID)
        
        query.observeSingleEvent(of: .value, with: { (dbSnapshot) in
            
            guard let snap: FIRDataSnapshot? = dbSnapshot else {
                print("No Reuslt Found")
                Utilities.sharedInstance.hideHUD(view: self.view)
                return
            }
            if snap?.value is NSNull
            {
                Utilities.sharedInstance.hideHUD(view: self.view)
            }
            else
            {
                var dict = snap?.value as! [String : AnyObject]
                let userId = Array(dict.keys)[0]
                dict = dict[userId] as! [String : AnyObject]
                
                UserDefaults.standard.set(dict["userName"], forKey:Constant.UserDefaultUserName)
                if userId != nil
                {
                    print ("user  found")
                }
                else {
                    print ("user not found")
                }
            }
        })
        {  (error) in
            print("test error")
        }
    }

    func submitwithstatuscode()
    {
        ref = FIRDatabase.database().reference()
        if self.statuscode == self.ACodeField.text!
        {
            self.ref.child("User_Profiles").child(self.userID).child("status").setValue("Activated",
                                                                                        withCompletionBlock: { (error, snapshot) in
                                                                                            if error != nil {
                                                                                                self.showAlertView(withTitle: "Error in updating code")
                                                                                                print("oops, an error")
                                                                                            } else {
                                                                                                //                                                                                            self.navigationController?.popToRootViewController(animated: true)
                                                                                                
                                                                                                //user is able to login into application
                                                                                                UserDefaults.standard.set(self.userID, forKey: "userdata")
                                                                                                UserDefaults.standard.set(true, forKey: Constant.isLoginSuccessFully)
                                                                                                UserDefaults.standard.set(self.userID, forKey:Constant.UserDefaultUserId)
                                                                                    self.setUserData()
                                                                                                                UserDefaults.standard.synchronize()
                                                                                                
                                                                                                
                                                                                                    //  Navigate to Home screen
                                                                                                    let timeLineViewController = self.storyboard?.instantiateViewController(withIdentifier: "reveal") as! SWRevealViewController
                                                                                                    self.navigationController?.pushViewController(timeLineViewController, animated: true)
                                                                                                
                                                                                                self.showAlertView(withTitle: "Your Acount is Successfully Activated")                           }
            })
            
        }else{
            showAlertView(withTitle: "Enter Valid Activation Code")
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters, options: [], range: string.startIndex ..< string.endIndex) == nil
    }
}

