//
//  BaseViewController.swift
//  CustoFood
//
//  Created by IbrahimK on 9/15/15.
//  Copyright (c) 2015 appyte. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, CAAnimationDelegate {

    var activityView: UIView?
    
    /// Show Progress HUD
    func showHUD () {
        if (navigationController != nil){
            MBProgressHUD.showAdded(to: (navigationController?.view)!, animated: true)
        } else {
            MBProgressHUD.showAdded(to: view, animated: true)
        }
    }
    
    /// Hide Progress HUD
    func hideHUD () {
        if (navigationController != nil) {
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
        } else {
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    //MARK: - Custom methods
    
    func addActivityIndicatorOnView() {
        if activityView == nil {
            let rect: CGRect = UIScreen.main.bounds
           
            activityView = UIView(frame: CGRect(x: 0, y: 0, width: rect.size.width, height:  rect.size.height))
            activityView!.backgroundColor = UIColor.black
            activityView!.alpha = 0.5
        }
        
        let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.center = activityView!.center
        activityIndicatorView.startAnimating()
        activityView!.addSubview(activityIndicatorView)
        (UIApplication.shared.delegate)?.window??.addSubview(activityView!)
        activityView!.isHidden = true
    }
    
    func shouldShowActivityOnView(show: Bool) {
        activityView!.isHidden = !show
        (UIApplication.shared.delegate)?.window??.bringSubview(toFront: activityView!)
    }
    
    func showActivityIndicator() {
        DispatchQueue.main.async() { () -> Void in
            self.addActivityIndicatorOnView()
            self.shouldShowActivityOnView(show: true)
        }
       
    }

    func hideActivityIndicator() {
        
        DispatchQueue.main.async() { () -> Void in
        
            self.shouldShowActivityOnView(show: false)

        }
    }
    
      func setbackroundcolor(view: UIView){
       
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Backroundimageinvi")
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(backgroundImage, at: 0)
           
    }
     func showAlertView(withTitle  title :String)
     {
        
        DispatchQueue.main.async() { () -> Void in
            
            let alertController = UIAlertController(title: NSLocalizedString("Alert", comment: "alert"), message:
                title, preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: "dismiss"), style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)

        }
        
    }
        
//    func isConnectedToNetwor() -> Bool{
//        
//        return Reachability.isConnectedToNetwork()
//        
//    }
    
    // create directory
    
    func createDirectory(){
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("Invitations_Created")
        if !fileManager.fileExists(atPath: paths){
            try! fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
        }else{
            print("Already dictionary created.")
        }
    }
    
    // Get  Directory path
    
   
 /*   func getDirectoryPath() -> NSURL {
        let paths= NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory: NSURL = paths[0]
        return documentsDirectory
    }*/
    
    // Save image in Directory
    
    func saveImageDocumentDirectory(image: UIImage, imagename: String){
        
        let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        //let mypath  = documentsDirectoryURL[0]
        
        // create a name for your image
        
        let fileURL = documentsDirectoryURL.appendingPathComponent("\(imagename)")
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let data: NSData  = UIImagePNGRepresentation(image)! as NSData
                try data.write(to: fileURL)
                print("Image Added Successfully")
                
            } catch {
                print(error)
            }
        } else {
            print("Image Not Added")
            showAlertView(withTitle: NSLocalizedString("Filename Already Exist", comment: "message") )
        }
        
       
    }
    
    // Get image from path
    
    func getImage()-> NSMutableArray{
        let imagesarray = NSMutableArray()
        let paths: [Any] = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true))
        let mypath:String = paths[0] as! String
        let fileManager = FileManager.default
        do {
            let filelist = try fileManager.contentsOfDirectory(atPath: mypath )
            
            for filename in filelist {
                imagesarray.add(filename)
                print(filename)
                let imagesss = UIImageView()
                
                imagesss.image = UIImage(named: filename)
            }
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
        
     return imagesarray
    }
    
    // Firebase analytics.
    
//    func analyticsreport(){
//        FIRAnalytics.logEvent(withName: "viewcontroller- \(NSLocalizedString("Anniversary", comment: "navigationItem.title") )", parameters: [
//            kFIRParameterItemID: "id-\(NSLocalizedString("Anniversary", comment: "navigationItem.title") )" as NSObject,
//            kFIRParameterItemName: "UIViewController" as NSObject,
//            kFIRParameterContentType: "VC is opened" as NSObject
//            ])
//    }
//    
//
//}

}
