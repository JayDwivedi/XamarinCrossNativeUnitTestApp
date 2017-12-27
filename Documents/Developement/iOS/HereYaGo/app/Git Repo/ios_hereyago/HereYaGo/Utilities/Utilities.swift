//
//  Utilities.swift
//  HereYaGo
//
//  Created by Pradip Walghude on 2017-08-11.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import UIKit
//import MBProgressHUD

struct Constant
{
  
    static let isLoginSuccessFully = "login_SuccessFully"
    static let UserDefaultEmail = "email"
    static let UserDefaultUserId = "userID"
    static let UserDefaultUserName = "userName"
}

class Utilities: NSObject {
    
    static let sharedInstance: Utilities = {
        let instance = Utilities()
        return instance
    }()
    
    // Show Progress HUD
    func showHUD(view : UIView)  {
        
        MBProgressHUD.showAdded(to: view, animated: true)
    }
    
    /// Hide Progress HUD
    func hideHUD (view : UIView) {
        
        MBProgressHUD.hideAllHUDs(for: view, animated: true)
    }
    
    
    /// show error message
    ///
    /// - Parameters:
    ///   - title: title for alert
    ///   - message: message for alert
    ///   - controller: which controller to display
    func showErrorMessage (_ title: String, message: String, controller: UIViewController){
        
        let alertMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertMessage.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        controller.present(alertMessage, animated: true, completion: nil)
    }
    
    
}

