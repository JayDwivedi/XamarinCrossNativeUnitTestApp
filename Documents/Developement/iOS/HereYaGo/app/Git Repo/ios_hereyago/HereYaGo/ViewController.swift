//
//  ViewController.swift
//  HereYaGo
//
//  Created by DawnShine on 12/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet var imgViewBG: UIView!
    @IBOutlet var imgBanner: UIImageView!
    @IBOutlet var pageControl: UIPageControl!
    
    var currentIndex = 0
    var reCall : Timer = Timer()
    var imageUrls = [("Banner 01","banner_01")
        , ("Banner 02","banner_02")
        , ("Banner 03","banner_03")
        ,("Banner 04","banner_04")]
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("ViewDidLoad")
        self.runTimer()
        self.addGesturetoImageView()
        
        self.navigationController?.navigationBar.isHidden = true

        if(UserDefaults.standard.bool(forKey: Constant.isLoginSuccessFully))
        {
            //  Navigate to Home screen
            let timeLineViewController = self.storyboard?.instantiateViewController(withIdentifier: "reveal") as! SWRevealViewController
            self.navigationController?.pushViewController(timeLineViewController, animated: true)
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func runTimer()
    {
        self.reCall = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(ViewController.reCalls), userInfo: nil, repeats: true)
    }
    
    func reCalls()
    {
        if(currentIndex < self.imageUrls.count-1)
        {
            currentIndex += 1
            //print("Current",currentIndex)
            self.pageControl.currentPage = currentIndex;
            self.changeImage(index: currentIndex);
            self.showAminationOnAdvert(subtype: kCATransitionFromRight);
        }
        else if (currentIndex >= 3)
        {
            currentIndex = 0
            self.pageControl.currentPage = currentIndex;
            self.changeImage(index: currentIndex);
            self.showAminationOnAdvert(subtype: kCATransitionFromLeft);
        }
    }
    
    func addGesturetoImageView()
    {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.respondToSwipeGesture(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.imgBanner.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.respondToSwipeGesture(gesture:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.imgBanner.addGestureRecognizer(swipeLeft)
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        //        print("respondToSwipeGesture")
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                //                print("Swiped right")
                if(currentIndex > 0) {
                    currentIndex -= 1
                    self.pageControl.currentPage = currentIndex;
                    showAminationOnAdvert(subtype: kCATransitionFromLeft);
                }
                changeImage(index: currentIndex);
            case UISwipeGestureRecognizerDirection.left:
                //                print("Swiped Left")
                if(currentIndex < self.imageUrls.count-1) {
                    currentIndex += 1
                    self.pageControl.currentPage = currentIndex;
                    showAminationOnAdvert(subtype: kCATransitionFromRight);
                }
                changeImage(index: currentIndex);
            default:
                print("Default")
                break
            }
        }
    }
    
    func showAminationOnAdvert(subtype :String)
    {
        let  transitionAnimation = CATransition();
        transitionAnimation.type = kCATransitionPush;
        transitionAnimation.subtype = subtype;
        
        transitionAnimation.duration = 0.5;
        transitionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
        transitionAnimation.fillMode = kCAFillModeBoth;
        
        imgBanner.layer.add(transitionAnimation, forKey: "fadeAnimation")
    }
    
    func changeImage(index:Int)
    {
        let (text,imageName) = self.imageUrls[index];
        print(text)
        
        self.imgBanner.image = UIImage(named: imageName)
    }
   
    @IBAction func changePageControl(sender: AnyObject)
    {
        if(self.currentIndex > self.pageControl.currentPage)
        {
            changeImage(index: self.pageControl.currentPage);
            showAminationOnAdvert(subtype: kCATransitionFromRight)
        }
        else if self.currentIndex < self.pageControl.currentPage
        {
            changeImage(index: self.pageControl.currentPage);
            showAminationOnAdvert(subtype: kCATransitionFromLeft)
        }
        self.currentIndex = self.pageControl.currentPage
    }
    
    @IBAction func btnLogin(_ sender: Any)
    {
        print("Login")
        self.reCall.invalidate()
        self.performSegue(withIdentifier: "GoToLogin", sender: self)
    }
   
    @IBAction func btnSignUp(_ sender: Any)
    {
        print("SignUp")
        self.reCall.invalidate()
        self.performSegue(withIdentifier: "GoToSignUp", sender: self)
    }
}

