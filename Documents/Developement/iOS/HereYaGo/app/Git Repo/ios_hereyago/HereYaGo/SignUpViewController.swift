//
//  SignUpViewController.swift
//  HereYaGo
//
//  Created by DawnShine on 12/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn
import FBSDKLoginKit
import TwitterKit

let KuserName = "username"
let KnickName = "nickname"
let Kmailid = "email"
let Kpassword = "password"
let KconformPW = "conformpassword"
let Kuserimage = "userimage"


class SignUpViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate , GIDSignInUIDelegate, FBSDKLoginButtonDelegate , GIDSignInDelegate {
    /**
     Sent to the delegate when the button was used to login.
     - Parameter loginButton: the sender
     - Parameter result: The results of the login
     - Parameter error: The error (if any) from the login
     */
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        //
    }

    var isFromSocial:Bool = false
    @IBOutlet var googlesignupbtn: GIDSignInButton!
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userNameField: UITextField!
    @IBOutlet var nickNmaeField: UITextField!
    @IBOutlet var mailIdField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var conformPWField: UITextField!
    
    var signinfoDict: [String: String] = [:]
    var ref = FIRDatabase.database().reference()
      var socailData : NSDictionary?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  ref = Firebase(url:"https://hereyago-d6632.firebaseio.com")
      //  authHelper = TwitterAuthHelper(firebaseRef: ref, twitterAppId: "PVJNxTV2qCrxoFRt00yGFJpOY")

    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func uploadimagetapped(_ sender: Any)
    {
        
      self.handleSelectProfileImageView()
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedimage = info[UIImagePickerControllerOriginalImage]
        userImage.image = selectedimage as! UIImage?
        dismiss(animated: true, completion: nil)
    }

    func isValidEmail() -> Bool
    {
        let testStr:String = self.mailIdField.text!

        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isSelectProfilePicture()-> Bool
    {
        return image(image1: userImage.image!, isEqualTo: UIImage.init(named: "upload")!)

    }
    
    func isValidPassword() -> Bool
    {
        var flag : Bool = false
        
        let lengthPassword = self.passwordField.text?.characters.count
        
        if lengthPassword! >= 6
        {
            if self.passwordField.text != self.conformPWField.text
            {
                self.showAlertView(withTitle: "Error : Password and confirm password must be equal")
            }
            else
            {
                flag = true
            }
        }
        else
        {
            self.showAlertView(withTitle: "Error : Password must be 6 characters long or more")
        }
        return flag
    }
    
    @IBAction func btnSignUpNext(_ sender: Any)
    {
        if  (userNameField.text?.characters.count)! > 0
        {
            if (nickNmaeField.text?.characters.count)! > 0
            {
                if isValidEmail()
                {
                    if isValidPassword()
                    {
                        if isSelectProfilePicture()
                        {
                        self.performSegue(withIdentifier: "GotoSignupAddress", sender: self)
                        }
                        else
                        {
                           self.showAlertView(withTitle: "Please select profile image.")
                        }
                    }
                }
                else
                {
                    self.showAlertView(withTitle: "Error : Please enter a valid email")
                }
            }
            else
            {
                self.showAlertView(withTitle: "Error : Please enter nick name")
            }
        }
        else
        {
            self.showAlertView(withTitle: "Error : Please enter a user name")
        }
    }
    
    func image(image1: UIImage, isEqualTo image2: UIImage) -> Bool
    {
        let data1: NSData = UIImagePNGRepresentation(image1)! as NSData
        let data2: NSData = UIImagePNGRepresentation(image2)! as NSData
        return (!(data1.isEqual(data2)))
    }
   
    @IBAction func actionBackButton(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }

    // Google signup
    @IBAction func googlesignupaction(_ sender: Any)
    {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    // Facebook Signup
    @IBAction func FBsignUpAction(_ sender: UIButton)
    {
        loginFacebookRequest()
    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!)
    {
        let firebaseAuth = FIRAuth.auth()
        do
        {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    // Twitter SignUp
    
    @IBAction func twitterSignUpAction(_ sender: Any)
    {
       self.authWithTwitter()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
        let defaults = UserDefaults.standard
        defaults.set(UIImagePNGRepresentation((userImage?.image)!), forKey: Kuserimage)
        
        let signupinfoDict:[String : String] = [KuserName: ((userNameField)?.text)!,
                                                KnickName:(nickNmaeField?.text)!,
                                                Kmailid:(mailIdField?.text)!,
                                                Kpassword:(passwordField?.text)!,
                                                KconformPW:(conformPWField?.text)!
        ]
        if segue.identifier == "GotoSignupAddress"
        {
            let signupcat : SignupAddressViewController = segue.destination as! SignupAddressViewController
            signupcat.signupinfoDict = signupinfoDict
            signupcat.isFromSocial = false
        }
    }

    func loginwithsocialData(socailData : NSDictionary)
    {
        let email:String = socailData.value(forKey:"email") as! String
        
        self.socailData = socailData
        if(socailData.value(forKey: "profilePic") != nil)
        {
            let defaults = UserDefaults.standard
            defaults.set(socailData.value(forKey: "profilePic"), forKey: Kuserimage)
        }
        ref = FIRDatabase.database().reference()
        
        self.userLookUpByEmail(email: email,isFromSocial: true)
        {
            (result: String) in
            if result != ""
            {
                // check if user detail is availbale
                self.gettingstatusdetails(emailID: email)
                {
                    (result: String) in
                    if result != ""
                    {
                        // login user
                        Utilities.sharedInstance.hideHUD(view: self.view)
                        self.loginwithFirebase(statusvalue: result, email: email)
                    }
                    else
                    {
                        Utilities.sharedInstance.hideHUD(view: self.view)
                        self.showAlertView(withTitle: "Invalid login email or password")
                    }
                }
            }else
            {
                Utilities.sharedInstance.hideHUD(view: self.view)
                self.showAlertView(withTitle: "Invalid login email or password")
            }
        }
    
    }
}


//Twitter login
extension SignUpViewController
{
    func authWithTwitter() {
        Twitter.sharedInstance().logIn(completion: { (session, error) in
            if (session != nil) {
                guard (session?.authToken) != nil else{return}
                guard (session?.authTokenSecret) != nil else{return}
                
                print("signed in as \(String(describing: session?.userName))");
                let credential = FIRTwitterAuthProvider.credential(withToken: (session?.authToken)!, secret: (session?.authTokenSecret)!)
                FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                    // ...
                    if let error = error {
                        print("error: \(error.localizedDescription)");
                        return
                    }
                    self.twitterResult(twitterData: user)
                    
                }
            }else {
                print("error: \(String(describing: error?.localizedDescription))");
            }
        })
    }
    
    func twitterResult(twitterData: FIRUser!)
    {
        let id : String = twitterData.providerID
        let username : String = twitterData.displayName!
        let email : String = twitterData.email!
        let gender : String = "1"
        let image : URL = twitterData.photoURL!
        
        let perameter = NSMutableDictionary()
        perameter.setValue( username, forKey: "name")
        perameter.setValue(email, forKey: "email")
        perameter.setValue(id, forKey: "socialID")
        perameter.setValue(2, forKey: "loginType")
        perameter.setValue("\(image)", forKey: "profilePic")
        perameter.setValue(gender, forKey: "gender")
        print(perameter)
        loginwithsocialData(socailData: perameter)
    }
}

// Google login
extension SignUpViewController
{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?)
    {
        if error != nil
        {
            print(error?.localizedDescription ?? "error")
            return
        }
        print("User signed into google")
        guard let authentication = user.authentication else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        Utilities.sharedInstance.showHUD(view: self.view)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            print("User Signed Into Firebase")
            let defaults = UserDefaults.standard
            defaults.set(true, forKey:"isLogin")
            
            self.gmailresult(gmailData: user)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!)
    {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func gmailresult(gmailData: FIRUser!)
    {
        if (gmailData) != nil
        {
            var id : String = "";
            id = gmailData.providerID
            let username : String = gmailData.displayName!
            let email : String = gmailData.email!
            let gender : String = "1"
            let image : URL = gmailData.photoURL!
            
            let perameter = NSMutableDictionary()
            perameter.setValue( username, forKey: "name")
            perameter.setValue(email, forKey: "email")
            perameter.setValue(id, forKey: "socialID")
            perameter.setValue(2, forKey: "loginType")
            perameter.setValue("\(image)", forKey: "profilePic")
            perameter.setValue(gender, forKey: "gender")
            print(perameter)
            loginwithsocialData(socailData: perameter)
        }
        else
        {
            print("Error : gMail Data nil")
        }
    }
}
//facebook login
extension SignUpViewController{
    
    
    /**
     * Facebook Login and Sign up function
     *
     */
    func loginFacebookRequest()
    {
        //        if(!supportingfuction.hasConnectivity())
        //        {
        //            supportingfuction.showMessageHudWithMessage(NoInternetConnection as NSString, delay: 2.0)
        //            return
        //        }
        FBSDKAccessToken.setCurrent(nil)
        let FBLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        
        // FBLoginManager.logIn(withReadPermissions:  ["email"], from: self, handler: { (FBSDKLoginManagerLoginResult, Error) in
        
        FBLoginManager.logIn(withReadPermissions: ["email"], from: self)
        { (result, Error) in
            
            Utilities.sharedInstance.showHUD(view: self.view)
            //supportingfuction.hideProgressHudInView()
            if Error != nil
            {
                // supportingfuction.showMessageHudWithMessage(RequestFail, delay: 2.0)
            } else if (result?.isCancelled)!
            {
                // Authorization has been canceled by user
                // supportingfuction.showMessageHudWithMessage("Request Cancelled", delay: 2.0)
            }else
            {
                // Authorization has been given by user
                print(" fb response ", result?.grantedPermissions.description as Any)
                self.populateUserDetails()
            }
        }
    }

    
    /**
     * populateUserDetails Function will return data from facebook.
     *
     */
    
    func populateUserDetails()
    {
        let params = [
            "fields" :"id, name, email , gender ,picture.redirect(false)"]
        //  supportingfuction.showProgressHud(Requesting, labelText: PleaseWait)
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: params as NSDictionary as! [AnyHashable: Any])
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            //   supportingfuction.hideProgressHudInView()
            
            if ((error) != nil)
            {
                Utilities.sharedInstance.hideHUD(view: self.view)
                // Process error
                print("Error: \(String(describing: error))")
            }
            else
            {
                let userFbData = result as! NSDictionary
                print(userFbData)
                if (userFbData["id"] as! String! == nil && userFbData["id"] as! String! == "") || (userFbData["name"] as! String! == nil && userFbData["name"] as! String! == "")
                {
                    //  supportingfuction.showMessageHudWithMessage(RequestFail, delay: 2.0)
                    Utilities.sharedInstance.hideHUD(view: self.view)
                    
                    let signup: SignUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
                    signup.isFromSocial = true
                    signup.userNameField.text = userFbData["name"] as? String
                    self.navigationController?.pushViewController(signup, animated: true)
                    return
                }
                else{
                    
                    //                    guard let authentication = user.authentication else { return }
                    
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    
                    //TODO:
                    
                    //                    FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                    //                        // ...
                    //                        if let error = error {
                    //                            print("error: \(error.localizedDescription)");
                    //                            Utilities.sharedInstance.hideHUD(view: self.view)
                    //                            return
                    //                        }
                    //                        self.facebookresult(serFbData: userFbData)
                    //                    }
                    
                    self.facebookresult(serFbData: userFbData)
                }
            }
        })
    }
    
    func facebookresult(serFbData: NSDictionary!)
    {
        let fb_id : String = serFbData["id"] as! String
        var email = ""
        var gender = "1"
        
        if serFbData["email"] != nil && serFbData["email"] as! String != ""
        {
            email = serFbData["email"] as! String
        }
        if serFbData["gender"] != nil && serFbData["gender"] as! String != ""
        {
            if "male" == serFbData["gender"] as! String
            {
                gender = "1"
                
            }else if "female" == serFbData["gender"] as! String
            {
                gender = "2"
            }else
            {
                gender = "3"
            }
        }
        
        //let image = "http://graph.facebook.com/\(fb_id)/picture?type=large"
        
        let perameter = NSMutableDictionary()
        perameter.setValue( (serFbData["name"] as! String), forKey: "name")
        perameter.setValue(email, forKey: "email")
        perameter.setValue(fb_id, forKey: "socialID")
        perameter.setValue(2, forKey: "loginType")
        let profilePicDict:NSDictionary = (serFbData.value(forKey: "picture") as! NSDictionary).value(forKey: "data") as! NSDictionary
        
        let data:String = profilePicDict.value(forKey: "url") as! String
        
        
        perameter.setValue(data, forKey: "profilePic")
        perameter.setValue(gender, forKey: "gender")
        print(perameter)
        loginwithsocialData(socailData: perameter)
        //self.performSegue(withIdentifier: "GoToActivationFromLogIn", sender: self)
    }
        
    func gettingstatusdetails(emailID: String, completionHandler: @escaping (_ result: String) -> Void)
    {
        ref = FIRDatabase.database().reference()
        
        DispatchQueue.main.async(execute:{
            
            let query = self.ref.child("User_Profiles").queryOrdered(byChild: "userEmail").queryEqual(toValue:emailID )
            query.observeSingleEvent(of: .value, with: { (snapshot) in
                
                
                guard let snap: FIRDataSnapshot? = snapshot else {
                    print("No Reuslt Found")
                    return
                }
                if snap?.value is NSNull
                {
                    Utilities.sharedInstance.hideHUD(view: self.view)
                    self.showAlertView(withTitle: "User Not registered")
                }
                else
                {
                    let dict:Dictionary = snap?.value as! [String : AnyObject]
                    let userId = Array(dict.keys)[0]
                    let userInfo =  dict[userId]
                    let statusvalue:String
                    
                    if let statusValue = userInfo!["status"]!
                    {
                        statusvalue =  userInfo!["status"]! as! String
                    }
                    else
                    {
                        statusvalue = "Activated"
                    }
                    completionHandler(statusvalue)
                }
            })
            //            self.ref.child("User_Profiles").child(userid).queryOrdered(byChild: "city").observeSingleEvent(of: .value, with: { snapshot in
            //                var statusvalue = ""
            //                if snapshot.value != nil {
            //                    print(snapshot.key)
            //                    statusvalue = snapshot.value as! String
            //                }
            //                else {
            //                    print ("Detail not found")
            //                }
            //                completionHandler(statusvalue)
            //            })
            //        })
        })
    }
    
    func loginwithFirebase(statusvalue: String,email:String)
    {
        // let email = txtUsername.text
        
        ref = FIRDatabase.database().reference()
        if statusvalue == "Activated" || statusvalue == "Verified"
        {
            Utilities.sharedInstance.hideHUD(view: self.view)
         
            let query = ref.child("User_Profiles").queryOrdered(byChild: "userEmail").queryEqual(toValue: email)
                
                query.observeSingleEvent(of: .value, with: { (dbSnapshot) in
                    
                    guard let snap: FIRDataSnapshot? = dbSnapshot else {
                        print("No Reuslt Found")
                        Utilities.sharedInstance.hideHUD(view: self.view)
                        return
                    }
                    if snap?.value is NSNull
                    {
                        Utilities.sharedInstance.hideHUD(view: self.view)
                        self.showAlertView(withTitle: "User Not registered")
                    }
                    else
                    {
                        let dict = snap?.value as! [String : AnyObject]
                        let userId = Array(dict.keys)[0]
                        
                        UserDefaults.standard.set(userId, forKey:Constant.UserDefaultUserId)
                        UserDefaults.standard.set(true, forKey: Constant.isLoginSuccessFully)
                        UserDefaults.standard.set(dict["name"], forKey:Constant.UserDefaultUserName)
                        
                        UserDefaults.standard.synchronize()
                        Utilities.sharedInstance.hideHUD(view: self.view)
                        self.performSegue(withIdentifier: "GoToTimeLine", sender: self)
                    }
                })
                {  (error) in
                    print("test error")
                }
            
        }else {
            
            Utilities.sharedInstance.hideHUD(view: self.view)
            self.submitStatusCode1(userEmail:email)
            let activationVC = self.storyboard?.instantiateViewController(withIdentifier: "ActivationViewController") as! ActivationViewController
            activationVC.userEmail = Kmailid
            activationVC.isFromLoginVC = true
          //  activationVC.userEmail = self.txtUsername.text!
            self.navigationController?.pushViewController(activationVC, animated: true)
            //self.performSegue(withIdentifier: "GoToActivationFromLogIn", sender: self)
            self.showAlertView(withTitle: "Your Account is not activated Check your Mail.")
        }
    }
    
    func submitStatusCode1(userEmail:String)
    {
        ref = FIRDatabase.database().reference()
        let query = ref.child("User_Profiles").queryOrdered(byChild: "userEmail").queryEqual(toValue:userEmail )
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let snap: FIRDataSnapshot? = snapshot else {
                print("No Reuslt Found")
                return
            }
            if snap?.value is NSNull
            {
                //self.showAlertView(withTitle: "User Not registered")
            }
            else
            {
                let dict:Dictionary = snap?.value as! [String : AnyObject]
                let userId = Array(dict.keys)[0]
                let userInfo =  dict[userId]
                
                self.sendStatusCode(uEmail: userEmail
                    , stausCode: userInfo!["otp"]! as! String)
            }
        })
    }
    
    func sendStatusCode(uEmail:String,stausCode:String)  {
        //create the url with URL
        let urlString = String(format: "http://itideology.com/hereyago-dev/webapi/?emailid=%@&code=%@",uEmail,stausCode)
        
        let url = URL(string: urlString)! //change the url
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // request.httpBody = statusCode.data(using: .utf8)
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
        }
        task.resume()
    }
    
    func userLookUpByEmail (email: String,isFromSocial : Bool,completionHandler: @escaping (_ result: String) -> Void)
    {
        let query = ref.child("User_Profiles").queryOrdered(byChild: "userEmail").queryEqual(toValue: email)
        
        query.observeSingleEvent(of: .value, with: { (dbSnapshot) in
            
            guard let snap: FIRDataSnapshot? = dbSnapshot else {
                print("No Reuslt Found")
                Utilities.sharedInstance.hideHUD(view: self.view)
                return
            }
            if snap?.value is NSNull
            {
                Utilities.sharedInstance.hideHUD(view: self.view)
                
                self.createUserWithData(socailData: self.socailData!)
               
            }
            else
            {
                let dict = snap?.value as! [String : AnyObject]
                let userId = Array(dict.keys)[0]
                if userId != nil
                {
                    print ("user  found")
                }
                else {
                    print ("user not found")
                }
                completionHandler(userId)
            }
        })
        {  (error) in
            print("test error")
        }
      
    }
    
    func createUserWithData(socailData : NSDictionary)
    {
        let signupinfoDictLocal:[String : String] = [KuserName: socailData.value(forKey:"name") as! String,
                                                     KnickName:socailData.value(forKey: "name") as! String,
                                                     Kmailid:socailData.value(forKey:"email") as! String,
                                                     "profilePic":socailData.value(forKey:"profilePic") as! String
        ]
        let signup: SignupAddressViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignupAddressViewController") as! SignupAddressViewController
        signup.signupinfoDict = signupinfoDictLocal
        signup.isFromSocial = true
        self.navigationController?.pushViewController(signup, animated: true)
        Utilities.sharedInstance.hideHUD(view: self.view)
        UserDefaults.standard.set(socailData, forKey: "userdata")
        UserDefaults.standard.synchronize()
        //self.performSegue(withIdentifier: "GoToTimeLine", sender: self)
    }
}
