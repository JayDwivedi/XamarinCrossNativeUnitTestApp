//
//  LoginViewController.swift
//  HereYaGo
//
//  Created by DawnShine on 12/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import GoogleSignIn
import TwitterKit

class LoginViewController: BaseViewController, GIDSignInUIDelegate ,GIDSignInDelegate  {
    
    @IBOutlet weak var btnRememberMe: UIButton!
    @IBOutlet var txtUsername: UITextField!
    @IBOutlet var txtPassword: UITextField!
    var isLoginButtonPressed : Bool = false
    var email:String = ""
    var socailData : NSDictionary?
    
    var ref = FIRDatabaseReference()

    override func viewDidLoad()
    {
        super.viewDidLoad()
//       if let _ = FIRAuth.auth()?.currentUser {
//            self.signIn()
//       }
        
//     self.txtUsername.text = "jaidwivedi20@icloud.com"
//     self.txtUsername.text = "sonsale.sachinu@gmail.com"
        self.txtUsername.text = "sachin@gmail.com"
     //   self.txtUsername.text = "bhagatsudheer77@gmail.com"
     //   self.txtUsername.text = "jaidwivedi20@icloud.com"

        //self.txtUsername.text = "walghudep@gmail.com"
         self.txtUsername.text = "pradipwalghude@gmail.com"

       // self.txtPassword.text = "jkdwivedi20"
         self.txtPassword.text = "654321"
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkNotAvailabelChanged),
            name: NSNotification.Name(rawValue: "NetworkGone"),
            object: nil)
    }
    
    func networkNotAvailabelChanged(notification: NSNotification)
    {
        //do stuff
        Utilities.sharedInstance.hideHUD(view: self.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   
    @IBAction func btnLogin(_ sender: Any)
    {
        isLoginButtonPressed = true
//        let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
//        connectedRef.observe(.value, with: { snapshot in
//            
//            if let connected = snapshot.value as? Bool, connected
//            {
//                self.Loginaction()
//            } else {
//                 self.showAlertView(withTitle: "Firebase Not Connected")
//            }
//        })
        self.Loginaction()
    }
    
    @IBAction func btnFacebook(_ sender: Any)
    {
        isLoginButtonPressed = false
        loginFacebookRequest()
    }
    
    @IBAction func actionBackButton(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnGooglePlus(_ sender: Any)
    {
        isLoginButtonPressed = false
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func btnTwitter(_ sender: Any)
    {
        isLoginButtonPressed = false
        authWithTwitter()
    }
    
    func signIn()
    {
        self.performSegue(withIdentifier: "GoToTimeLine", sender: self)
    }
    
    @IBAction func actionRememberMe(_ sender: Any)
    {
        if self.btnRememberMe.tag == 0
        {
            self.btnRememberMe.tag = 1
            self.btnRememberMe.setImage(UIImage(named: "selected-remember-box")?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        else
        {
            self.btnRememberMe.tag = 0
            self.btnRememberMe.setImage(UIImage(named: "remember-box")?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
    
    @IBAction func btnForgotPassword(_ sender: Any)
    {
        print("Forgot Password")
        let prompt = UIAlertController(title: "Password Reset", message: "Email:", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            let userInput = prompt.textFields![0].text
            if (userInput!.isEmpty) {
                return
            }
            Utilities.sharedInstance.showHUD(view: self.view)
            FIRAuth.auth()?.sendPasswordReset(withEmail: userInput!, completion: { (error) in
                if let error = error {
                    Utilities.sharedInstance.hideHUD(view: self.view)
                    if let errCode = FIRAuthErrorCode(rawValue: error._code) {
                        switch errCode {
                        case .errorCodeUserNotFound:
                            DispatchQueue.main.async {
                                self.showAlertView(withTitle: "User account not found. Try registering")
                            }
                        default:
                            DispatchQueue.main.async {
                                self.showAlertView(withTitle: "Error: \(error.localizedDescription)")
                            }
                        }
                    }
                    return
                } else {
                    Utilities.sharedInstance.hideHUD(view: self.view)
                    DispatchQueue.main.async {
                        self.showAlertView(withTitle: "You'll receive an email shortly to reset your password.")
                    }
                }
            })
        }
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil)
    }
    
    func signUpUserWithData(socailData : NSDictionary)
    {
        self.email = socailData[Kmailid] as! String
        let password = "123456"
        ref = FIRDatabase.database().reference()
        FIRAuth.auth()?.createUser(withEmail: self.email , password: password, completion: { (user, error) in
            
            if let error = error
            {
                Utilities.sharedInstance.hideHUD(view: self.view)
                if let errCode = FIRAuthErrorCode(rawValue: error._code)
                {
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
                Utilities.sharedInstance.hideHUD(view: self.view)
                self.showAlertView(withTitle: "User is registered");
                Utilities.sharedInstance.hideHUD(view: self.view)
                UserDefaults.standard.set(socailData, forKey: "userdata")
                UserDefaults.standard.synchronize()
                self.performSegue(withIdentifier: "GoToTimeLine", sender: self)
            }
        })
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
        
        
       // DispatchQueue.main.sync(execute:{
            /*
            let query = self.ref.child("User_Profiles").queryOrdered(byChild: "userEmail").queryEqual(toValue:self.txtUsername.text )
            query.observeSingleEvent(of: .value, with: { (snapshot) in
                
                
                guard let snap: FIRDataSnapshot? = snapshot else {
                    print("No Reuslt Found")
                    return
                }
                if snap?.value is NSNull
                {
                    Utilities.sharedInstance.hideHUD(view: self.view)
                    self.showAlertView(withTitle: "User Not registered")
                    self.createUserWithData(socailData: socailData)
                }
                else
                {
                    Utilities.sharedInstance.hideHUD(view: self.view)
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
                    UserDefaults.standard.set(userId, forKey:Constant.UserDefaultUserId)
                    
                    self.performSegue(withIdentifier: "GoToTimeLine", sender: self)
                }
            })
       // })
        
*/
        
//        ref.child("User_Profiles").queryOrdered(byChild: "userEmail").queryEqual(toValue:email).observeSingleEvent(of: .value, with: { snapshot in
//            
//            Utilities.sharedInstance.hideHUD(view: self.view)
//            if snapshot.value != nil
//            {
//                self.performSegue(withIdentifier: "GoToTimeLine", sender: self)
//            }
//            else
//            {
//                self.createUserWithData(socailData: socailData)
//            }
//  })
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "GoToActivationFromLogIn"
        {
            let navigationController = segue.destination as? UINavigationController  
            let ActivationVC : ActivationViewController = (navigationController!.topViewController as? ActivationViewController)!
            if isLoginButtonPressed == true
            {
                ActivationVC.userEmail = self.txtUsername.text!
            }
            else
            {
                ActivationVC.userEmail = email
            }
        }
        if segue.identifier == "GoToTimeLine"
        {
        }
    }
}

// email login by firebase
extension LoginViewController
{
    func Loginaction()
    {
        let email = txtUsername.text
        ref = FIRDatabase.database().reference()
        
       Utilities.sharedInstance.showHUD(view: self.view)
        // check if email is register or not
        self.userLookUpByEmail(email: email!, isFromSocial: false)
        {
            (result: String) in
            if result != ""
            {
                // check if user detail is availbale
                self.gettingstatusdetails(emailID: email!)
                {
                    (result: String) in
                    if result != ""
                    {
                        // login user
                        Utilities.sharedInstance.hideHUD(view: self.view)
                        self.loginwithFirebase(statusvalue: result, email: email!)
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
                
                if isFromSocial == true
                {
                    self.createUserWithData(socailData: self.socailData!)
                }
                else
                {
                    self.showAlertView(withTitle: "User Not registered")
                }
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

    
        
//        ref.child("User_Profiles").queryOrdered(byChild: "userEmail").queryEqual(toValue: email).observeSingleEvent(of: .childAdded, with: { snapshot in
//
//            var userId = ""
//            if snapshot.value != nil {
//                userId = snapshot.key
//            }
//            else {
//                print ("user not found")
//                
//            }
//            completionHandler(userId)
//        })
//        {  (error) in
//            print("test error")
//        }
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
    //
    
    func setUserData(email: String)
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
    func loginwithFirebase(statusvalue: String,email:String)
    {
       // let email = txtUsername.text
        let password = txtPassword.text
        
        ref = FIRDatabase.database().reference()
        if statusvalue == "Activated" || statusvalue == "Verified"
        {
            Utilities.sharedInstance.hideHUD(view: self.view)
            
            if isLoginButtonPressed == true
            {
                FIRAuth.auth()?.signIn(withEmail: email, password: password!, completion: { (user, error) in
                    guard let _ = user else {
                        Utilities.sharedInstance.hideHUD(view: self.view)
                        if let error = error {
                            if let errCode = FIRAuthErrorCode(rawValue: error._code) {
                                switch errCode
                                {
                                case .errorCodeUserNotFound:
                                    self.showAlertView(withTitle: "User account not found. Try registering")
                                case .errorCodeWrongPassword:
                                    self.showAlertView(withTitle: "Incorrect username/password combination")
                                default:
                                    self.showAlertView(withTitle: "Error: \(error.localizedDescription)")
                                }
                            }
                            return
                        }
                        assertionFailure("user and error are nil")
                        return
                    }
                    var userDict:Dictionary = ["email":user?.uid]
                    if user?.email != nil
                    {
                        userDict.updateValue(user?.email, forKey: "email")
                        self.setUserData(email: (user?.email)!)
                    }
                    //user is able to login into application
                    UserDefaults.standard.set(user?.uid, forKey: "userdata")
                    UserDefaults.standard.set(true, forKey: Constant.isLoginSuccessFully)
                    UserDefaults.standard.set(user?.uid, forKey:Constant.UserDefaultUserId)
                    
                    UserDefaults.standard.synchronize()
                    Utilities.sharedInstance.hideHUD(view: self.view)
                    self.performSegue(withIdentifier: "GoToTimeLine", sender: self)
                })
            }
            else
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
                        self.showAlertView(withTitle: "User Not registered")
                    }
                    else
                    {
                        var dict = snap?.value as! [String : AnyObject]
                        let userId = Array(dict.keys)[0]
                        dict = dict[userId] as! [String : AnyObject]
                        UserDefaults.standard.set(userId, forKey:Constant.UserDefaultUserId)
                        UserDefaults.standard.set(true, forKey: Constant.isLoginSuccessFully)
                        UserDefaults.standard.set(dict["userName"], forKey:Constant.UserDefaultUserName)

                        UserDefaults.standard.synchronize()
                        Utilities.sharedInstance.hideHUD(view: self.view)
                        self.performSegue(withIdentifier: "GoToTimeLine", sender: self)
                    }
                })
                {  (error) in
                    print("test error")
                }
            }
        }else{
            
            Utilities.sharedInstance.hideHUD(view: self.view)
            self.submitStatusCode1(userEmail:email)
            let activationVC = self.storyboard?.instantiateViewController(withIdentifier: "ActivationViewController") as! ActivationViewController
            activationVC.userEmail = Kmailid
            activationVC.isFromLoginVC = true
            activationVC.userEmail = self.txtUsername.text!
            self.navigationController?.pushViewController(activationVC, animated: true)
            //self.performSegue(withIdentifier: "GoToActivationFromLogIn", sender: self)
            self.showAlertView(withTitle: "Your Account is not activated Check your Mail.")
        }
    }
}
    
//MARK:- Twitter login
extension LoginViewController
{
    func authWithTwitter() {
      
        Twitter.sharedInstance().logIn(completion: { (session, error) in
            if (session != nil) {
                guard (session?.authToken) != nil else{return}
                guard (session?.authTokenSecret) != nil else{return}
                
                print("signed in as \(String(describing: session?.userName))");
                
                let client = TWTRAPIClient.withCurrentUser()
              //  var paramDict : NSDictionary ;
                
                
                client.requestEmail { email, error in
                    if (email != nil) {
                        print("signed in as \(String(describing: session?.userName))");
                   //   paramDict.setValue(email, forKey: "email")
                    } else {
                        print("error: \(String(describing: error?.localizedDescription))");
                        
                        Utilities.sharedInstance.hideHUD(view: self.view)
                        
                        let signup: SignUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
                        signup.isFromSocial = true
                        self.navigationController?.pushViewController(signup, animated: true)
                        return
                    }
                }
                
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
        var email : String = "";
        var image : URL = NSURL.init(string: "") as! URL
        
        
        if(twitterData.email != nil)
        {
            email  = twitterData.email!
        }
        let gender : String = "1"
        
        if(twitterData.photoURL != nil)
        {
           image  = twitterData.photoURL!
        }
        
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

// MARK:- G+
// Google login
extension LoginViewController
{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?)
    {
        
        if error != nil {
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

// MARK:- FB
//facebook login
extension LoginViewController
{
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
}
