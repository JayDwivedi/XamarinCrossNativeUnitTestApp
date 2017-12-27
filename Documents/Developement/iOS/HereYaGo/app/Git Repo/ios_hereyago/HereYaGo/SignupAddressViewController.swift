//
//  SignupAddressViewController.swift
//  HereYaGo
//
//  Created by Dawn on 23/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import UIKit
import CoreLocation

let Kusermobile = "usermobile"
let Kuserdoorno = "userdoor"
let Kuserstreet = "userstreet"
let Kusercity = "usercity"
let Kuserstate = "userstate"
let Kusercountry = "usercountry"
let KuserZip = "userzip"
let Klongitute = "userlongitute"
let Klattitute = "userlatitute"


class SignupAddressViewController: BaseViewController, CLLocationManagerDelegate {
    
    @IBOutlet var mobilefield: UITextField!
    @IBOutlet var doornofield: UITextField!
    @IBOutlet var streetfield: UITextField!
    @IBOutlet var cityfield: UITextField!
    @IBOutlet var statefield: UITextField!
    @IBOutlet var countryfield: UITextField!
    @IBOutlet var zipcodefield: UITextField!
  
    var isFromSocial:Bool = false
    var signupinfoDict:[String : String] = [:]
    var locationManager:CLLocationManager!
    let geocoder = CLGeocoder()
    var placeMark: CLPlacemark!
    var longvalue: String?
    var latitute: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        determineMyCurrentLocation()
    }
    
    func getdatafromaddress()
    {
        var location: String = "some address, state, and zip"
        let geocoder: CLGeocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count != 0 {
                    let coordinates = placemarks.first!.location
               //     latitute = "\(coordinates.latitude)"
                 //   longvalue = "\(coordinates.longitude)"
                }
            }
        }

                
             //   var placemark: MKPlacemark = MKPlacemark(placemark: topResult)
            //    var region: MKCoordinateRegion = self.mapView.region
             //   region.center = placemark.region.center
           //     region.span.longitudeDelta /= 8.0
           //     region.span.latitudeDelta /= 8.0
           //     self.mapView.setRegion(region, animated: true)
            //    self.mapView.addAnnotation(placemark)
        //    }
      //  } as! CLGeocodeCompletionHandler)
    }
    
    
    func determineMyCurrentLocation()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled()
        {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
        latitute = "\(userLocation.coordinate.latitude)"
        longvalue = "\(userLocation.coordinate.longitude)"
        let location = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        geocoder.reverseGeocodeLocation(location, completionHandler: {
            placemarks, error in
          //  placeMark = placemarks?[0]
            if error == nil && (placemarks?.count)! > 0
            {
                self.placeMark = (placemarks?.last)!
                print("\(self.placeMark!.thoroughfare)\n\(self.placeMark.administrativeArea)\n\(self.placeMark!.postalCode) \(self.placeMark!.locality)\n\(String(describing: self.placeMark!.country))")
                self.streetfield.text = self.placeMark!.thoroughfare!
                self.cityfield.text = self.placeMark!.locality
                self.countryfield.text = self.placeMark!.country
                self.zipcodefield.text = self.placeMark!.postalCode
                self.statefield.text = self.placeMark.administrativeArea!
                //self.manager.stopUpdatingLocation()
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }

    func validateData() -> Bool
    {
        if  (mobilefield.text?.characters.count)! > 0
        {
            if (mobilefield.text?.characters.count)! == 10
            {
                if  (doornofield.text?.characters.count)! > 0
                {
                    if  (streetfield.text?.characters.count)! > 0
                    {
                        if  (cityfield.text?.characters.count)! > 0
                        {
                            if  (statefield.text?.characters.count)! > 0
                            {
                                if  (countryfield.text?.characters.count)! > 0
                                {
                                    if  (zipcodefield.text?.characters.count)! > 0
                                    {
                                        return true
                                    }
                                    else
                                    {
                                        self.showAlertView(withTitle: "Error : Please enter a zipcode")
                                    }
                                }
                                else
                                {
                                    self.showAlertView(withTitle: "Error : Please enter a country")
                                }
                            }
                            else
                            {
                                self.showAlertView(withTitle: "Error : Please enter a state")
                            }
                        }
                        else
                        {
                            self.showAlertView(withTitle: "Error : Please enter a city")
                        }
                    }
                    else
                    {
                        self.showAlertView(withTitle: "Error : Please enter a street")
                    }
                }
                else
                {
                    self.showAlertView(withTitle: "Error : Please enter a door number")
                }
            }
            else
            {
                self.showAlertView(withTitle: "Error : Mobile number should be 10 digit")
            }
        }
        else
        {
            self.showAlertView(withTitle: "Error : Please enter mobile number")
        }
        return false
    }
    
    @IBAction func SignupaddressnextAction(_ sender: Any)
    {
        if validateData()
        {
            self.performSegue(withIdentifier: "GotoSignUpCategory", sender: self)
        }
    }
    @IBAction func SignupAddressPreviousAction(_ sender: Any)
    {
        self.navigationController?.popViewController(animated:true)
       // self.performSegue(withIdentifier: "SignUpProfile", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(latitute == nil)
        {
            latitute = "0";
        }
        if(longvalue == nil)
        {
            longvalue = "0";
        }
        
        let signupaddressDict:[String : String] =  [Kusermobile: ((mobilefield)?.text)!,
                                          Kuserdoorno:(doornofield?.text)!,
                                          Kuserstreet:(streetfield.text)!,
                                          Kusercity:(cityfield?.text)!,
                                          Kuserstate:(statefield?.text)!,
                                          Kusercountry:(countryfield?.text)!,
                                          KuserZip:(zipcodefield?.text)!,
                                          Klongitute: longvalue!,
                                          Klattitute: latitute!
                                           ]
   
        if segue.identifier == "GotoSignUpCategory"
        {
            let signupcat : SignUpViewControllerCategory = segue.destination as! SignUpViewControllerCategory
            signupinfoDict.updateDict(anotherDict: signupaddressDict)
            signupcat.isFromSocial = self.isFromSocial
            signupcat.previewDict = signupinfoDict
        }
    }
}

extension Dictionary
{
    mutating func updateDict(anotherDict:Dictionary) {
        for (key,value) in anotherDict
        {
            self.updateValue(value, forKey:key)
        }
    }
}
