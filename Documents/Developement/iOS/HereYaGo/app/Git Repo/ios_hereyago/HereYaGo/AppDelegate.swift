//
//  AppDelegate.swift
//  HereYaGo
//
//  Created by DawnShine on 12/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit
import Fabric
import TwitterKit
import CoreLocation
import GoogleSignIn
import CoreLocation

//let kTwitterConsumerKey = "PVJNxTV2qCrxoFRt00yGFJpOY"
//let kTwitterConsumerSecret = "BtakY9XepIDSxxIYgwzXPwhFWapWZVWZdnjdgZMAyRTmKE2zrU"

//  My account details.
let kTwitterConsumerKey = "AWsIuh3KhdNIgBwxcNEhfk4J3"
let kTwitterConsumerSecret = "frCZ8cKfMwMx5kok24CQiZ42bZh3hu8iUOyaQxlBnNEvxM6lt5"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate,CLLocationManagerDelegate{

    var window: UIWindow?
    private var reachability:Reachability!;
    
  var locationManager: CLLocationManager!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.sharedManager().enable = true
        FIRApp.configure()
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
       // GIDSignIn.sharedInstance().delegate = self
        Twitter.sharedInstance().start(withConsumerKey: kTwitterConsumerKey, consumerSecret: kTwitterConsumerSecret)
        Fabric.with([Twitter.sharedInstance()])
        initializeLocationUpdates()

        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        setupReachability(nil, useClosures: true)
        startNotifier()
        FIRDatabase.database().persistenceEnabled = true
        return true
    }
    
    func initializeLocationUpdates () {
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways     // Check authorization for location tracking
        {
            locationManager.requestWhenInUseAuthorization()                    // LocationManager will callbackdidChange... once user responds
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    func setupReachability(_ hostName: String?, useClosures: Bool)
    {
        
                let reachability = hostName == nil ? Reachability() : Reachability(hostname: hostName!)
        self.reachability = reachability
        
        if useClosures {
            reachability?.whenReachable = { reachability in
                DispatchQueue.main.async {
                    print("reachbale")
                }
            }
            reachability?.whenUnreachable = { reachability in
                DispatchQueue.main.async {
                    print("not reachbale")
                    // Post notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NetworkGone"), object: nil)
                }
            }
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: reachability)
        }
    }
    
    func startNotifier() {
        print("--- start notifier")
        do {
            try reachability?.startNotifier()
        } catch {
           
            return
        }
    }
    
    func stopNotifier() {
        print("--- stop notifier")
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        reachability = nil
    }

    func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        
        if reachability.isReachable
        {
            print("network")
        } else {
            print("not reachable")
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
//        self.saveContext()
    }
    
    // Google sigin
    
   public func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let googleDidHandle = GIDSignIn.sharedInstance().handle(url,
                                                                sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                                annotation: [:])
        let facebookDidHandle = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        let twitterDidHandle = Twitter.sharedInstance().application(application, open:url, options: options)
        
        return   facebookDidHandle || googleDidHandle || twitterDidHandle;
    }
    
  public   func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
            let googleDidHandle = GIDSignIn.sharedInstance().handle(url,sourceApplication: sourceApplication,annotation: annotation)
            let facebookDidHandle = FBSDKApplicationDelegate.sharedInstance().application(
                application,
                open: url as URL!,
                sourceApplication: sourceApplication,
                annotation: annotation
            )
            return   facebookDidHandle || googleDidHandle
        }
    
  public  func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool
    {
        
        let sourceApplication: String? = options["UIApplicationOpenURLOptionsSourceApplicationKey"] as? String
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url as URL!, sourceApplication: sourceApplication, annotation: nil)
        
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
       
        if error != nil {
            print(error?.localizedDescription ?? "DefaultValue")
            return
        }
         print("User signed into google")
        guard let authentication = user.authentication else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            print("User Signed Into Firebase")
            print(user?.email ?? "DefaultValue")
            print(user?.displayName ?? "DefaultValue")
            print(user?.photoURL ?? "DefaultValue")
            
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    // Facebook
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
    
    }
    


//  MARK:- CLLocationManager delegates .
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("Locatiion delegate call")
    }

private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    switch status {
    case .notDetermined:
        locationManager.requestAlwaysAuthorization()
        break
    case .authorizedWhenInUse:
        locationManager.startUpdatingLocation()
        break
    case .authorizedAlways:
        locationManager.startUpdatingLocation()
        break
    case .restricted:
        // restricted by e.g. parental controls. User can't enable Location Services
        break
    case .denied:
        // user denied your app access to Location Services, but can grant access from Settings.app
        break
    default:
        break
    }
}

/// stop Updating Location
func stopUpdatingLocation() -> Void {
    locationManager?.stopUpdatingLocation()
}

}

//  com.googleusercontent.apps.866015408773-8ip7o1ijut6aonve1276qlkjt9186hmp
