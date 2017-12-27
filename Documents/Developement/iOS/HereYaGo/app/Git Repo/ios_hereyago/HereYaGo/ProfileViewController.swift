//
//  ProfileViewController.swift
//  HereYaGo
//
//  Created by DawnShine on 15/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage


class ProfileViewController : BaseViewController,UITableViewDataSource,UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var lblRank: UILabel!
    @IBOutlet weak var lblBadges: UILabel!
    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet var ProfileTable: UITableView!
    @IBOutlet var profileimage: UIImageView!
    
    @IBOutlet weak var badgesAndRankLabel: UILabel!
    
    @IBOutlet var profilename: UILabel!
    @IBOutlet var BadgesView: UIView!
    @IBOutlet var SharesView: UIView!
    @IBOutlet var MyShareBtn: UIButton!
    @IBOutlet var MyBadgesBtn: UIButton!
    @IBOutlet var MyShinesBtn: UIButton!
    @IBOutlet var changeLbl: UILabel!
    @IBOutlet var BadgesCOllections: UICollectionView!
    var mybadges, myshare, myshine : Bool!
    var ref: FIRDatabaseReference!
    var storageREF : FIRStorageReference!
    var userDict = [Usersdetails]()
    var myshares = [shareitem]()
    var selectedindex: Int!
    var badgescount : Int!
    var rankCount : Int!

    var Badgeimagesaarray = ["shield-lg01", "shield-lg02", "shield-lg03", "shield-lg04", "shield-lg05", "shield-lg06", "shield-lg07", "shield-lg08", "shield-lg09"]
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        badgescount = self.getbadgescount()
        print(badgescount)
        self.myshare = true
        self.mybadges = false
        self.myshine = false
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        self.badgesAndRankLabel.text = ""
        if revealViewController() != nil
        {
            //revealViewController().rearViewRevealWidth = 62
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rightViewRevealWidth = 150
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
       //self.BadgesView.isHidden = true
        self.displayUserdata()
        self.getmysharesdata()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        self.profileimage.clipsToBounds = true
        self.profileimage.layer.cornerRadius = self.profileimage.frame.size.width/2
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
   
    @IBAction func buttontapped(_ sender: UIButton)
    {
        
        let selected = sender.tag
        switch selected {
        case 100:
            self.SharesView.slideInFromLeft()
            UIView.animate(withDuration: 0.5, animations: {
                self.changeLbl.frame = CGRect(x: self.MyShareBtn.frame.origin.x, y: self.changeLbl.frame.origin.y, width: self.MyShareBtn.frame.size.width, height: self.changeLbl.frame.size.height )
                self.MyShareBtn.backgroundColor = UIColor.init(colorLiteralRed: 5.0/255.0, green: 46.0/255.0, blue: 89.0/255.0, alpha: 1)
                self.MyBadgesBtn.backgroundColor = UIColor.init(colorLiteralRed: 9.0/255.0, green: 71.0/255.0, blue: 138.0/255.0, alpha: 1)
                self.MyShinesBtn.backgroundColor = UIColor.init(colorLiteralRed: 9.0/255.0, green: 71.0/255.0, blue: 138.0/255.0, alpha: 1)
            })
            self.myshare = true
            self.mybadges = false
            self.myshine = false
            
            self.BadgesView.isHidden = true
            self.SharesView.isHidden = false
            self.getmysharesdata()
            break
        case 200:
            if (self.myshare == true){
                self.SharesView.slideInFromRight()
            }
            else if (self.myshine == true){
                self.SharesView.slideInFromLeft()
            }
            UIView.animate(withDuration: 0.5, animations: {
                self.changeLbl.frame = CGRect(x: self.MyBadgesBtn.frame.origin.x, y: self.changeLbl.frame.origin.y, width: self.MyBadgesBtn.frame.size.width, height: self.changeLbl.frame.size.height )
                self.MyShareBtn.backgroundColor = UIColor.init(colorLiteralRed: 9.0/255.0, green: 71.0/255.0, blue: 138.0/255.0, alpha: 1)
                self.MyBadgesBtn.backgroundColor = UIColor.init(colorLiteralRed: 5.0/255.0, green: 46.0/255.0, blue: 89.0/255.0, alpha: 1)
                self.MyShinesBtn.backgroundColor = UIColor.init(colorLiteralRed: 9.0/255.0, green: 71.0/255.0, blue: 138.0/255.0, alpha: 1)
            })

            self.BadgesView.isHidden = false
            self.SharesView.isHidden = true
            self.myshine = false
            self.myshare = false
            self.mybadges = true
            break
        case 300:
            self.SharesView.slideInFromRight()
            UIView.animate(withDuration: 0.5, animations: {
                self.changeLbl.frame = CGRect(x: self.MyShinesBtn.frame.origin.x, y: self.changeLbl.frame.origin.y, width: self.MyShinesBtn.frame.size.width, height: self.changeLbl.frame.size.height )
                self.MyShareBtn.backgroundColor = UIColor.init(colorLiteralRed: 9.0/255.0, green: 71.0/255.0, blue: 138.0/255.0, alpha: 1)
                self.MyBadgesBtn.backgroundColor = UIColor.init(colorLiteralRed: 9.0/255.0, green: 71.0/255.0, blue: 138.0/255.0, alpha: 1)
                self.MyShinesBtn.backgroundColor = UIColor.init(colorLiteralRed: 5.0/255.0, green: 46.0/255.0, blue: 89.0/255.0, alpha: 1)
            })

            self.BadgesView.isHidden = true
            self.SharesView.isHidden = false
            self.getmyshinesdata()
            self.myshine = true
            self.myshare = false
            self.mybadges = false
            break
        default:
            self.BadgesView.isHidden = true
            self.SharesView.isHidden = false

            self.SharesView.slideInFromLeft()
            UIView.animate(withDuration: 0.5, animations: {
                self.changeLbl.frame = CGRect(x: self.MyShareBtn.frame.origin.x, y: self.changeLbl.frame.origin.y, width: self.MyShareBtn.frame.size.width, height: self.changeLbl.frame.size.height )
                self.MyShareBtn.backgroundColor = UIColor.init(colorLiteralRed: 5.0/255.0, green: 46.0/255.0, blue: 89.0/255.0, alpha: 1)
                self.MyBadgesBtn.backgroundColor = UIColor.init(colorLiteralRed: 9.0/255.0, green: 71.0/255.0, blue: 138.0/255.0, alpha: 1)
                self.MyShinesBtn.backgroundColor = UIColor.init(colorLiteralRed: 9.0/255.0, green: 71.0/255.0, blue: 138.0/255.0, alpha: 1)
            })
            self.myshare = true
            self.mybadges = false
            self.myshine = false
            self.getmysharesdata()
            break
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        return 247;
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.myshares.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let profileCell : ProfileViewControllerCell = ProfileTable.dequeueReusableCell(withIdentifier: "profilecells", for: indexPath) as! ProfileViewControllerCell
        
      // var user = Usersdetails()
        profileCell.lblMemberName.tag = indexPath.row
        profileCell.imgMember.tag = indexPath.row
        profileCell.lblMemberName.text = UserDefaults.standard.object(forKey: "username") as! String?
        
        if let userimageimg : String = UserDefaults.standard.object(forKey: "userimage") as! String{
            

           // self.profileimage.sd_setImage(with: NSURL.fileURL(withPath: userimageimg as! String), placeholderImage: UIImage(named: "upload"))
          
            
            profileCell.imgMember.layer.cornerRadius =  profileCell.imgMember.frame.size.width/2;
            profileCell.imgMember.clipsToBounds = true
        
        }else{
            profileCell.imgMember.image = UIImage(named: "upload")
        }
        var myshare = shareitem()
        myshare = myshares[indexPath.row]
//        profileCell.btnComment.tag = indexPath.row
//        profileCell.btnLike.tag = indexPath.row
        profileCell.lblProductName.text = myshare.itemtitle
        profileCell.lbldate.text = myshare.postdate
        profileCell.lblProductDescription.text = myshare.itemdes
        
        
//        var lks : String! = myshare.likesForPost;
//        lks = lks+" likes"
//        profileCell.lblLikesCount.text = "\(myshare.likesCount!) Likes"
//        
//        var pts : String = myshare.userPoints
//        pts = pts+" Points"
//        profileCell.lblPoints.text! = pts
//        
//        var coments : String  = myshare.commentsCount
//        coments = coments + "Comments"
//        profileCell.lblComments.text! = coments
        
        if let itemimg = myshare.itemimage
        {
          profileCell.imgProduct.sd_setImage(with: URL(string: itemimg), placeholderImage: UIImage(named: "login-bg"))
        } else{
            profileCell.imgProduct.image = UIImage(named: "login-bg")
        }
        profileCell.pathDB = self.myshares[indexPath.row].path!
//        profileCell.btnLike.addTarget(self, action: #selector(self.likebuttonbuttonTapped), for: .touchUpInside) 
//        profileCell.btnComment.addTarget(self, action: #selector(self.commentbuttontapped), for: .touchUpInside)
        
        if (self.myshare == true)
        {
            profileCell.btnRateProduct.setImage(UIImage(named: "deleteIcon"), for: .normal)
        }
        else if (self.myshine == true){
           profileCell.btnRateProduct.setImage(UIImage(named: "points_filled"), for: .normal)
        }
        profileCell.btnRateProduct.tag = indexPath.row
        
        profileCell.btnRateProduct.isHidden = false
        
        profileCell.btnRateProduct.addTarget(self, action: #selector(actionBtnRateProduct), for: UIControlEvents.touchUpInside)
        profileCell.btnTopShare.isHidden = true
        profileCell.lblMemberDetails.text = String(format: "%@ %@",lblBadges.text!,lblRank.text!)
        
        return profileCell
    }
    
    func actionBtnRateProduct(_ sender:UIButton)
    {
        // delete post from my favourites
        var myshare = shareitem()
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
        if self.myshine == false
        {
            if sender.tag < myshares.count
            {
                myshare = myshares[sender.tag]
                print("btn Rate Product\(myshare)")
                ref = FIRDatabase.database().reference()
                
                ref.child("User_Profiles").child(userID).child("Myshares").child(myshare.path!).removeValue() { (error, ref) in
                    
                    if error != nil
                    {
                        print("error \(String(describing: error))")
                    }
                    else
                    {
                        self.getmysharesdata()
                    }
                }
            }
        }
        else
        {
            if sender.tag < myshares.count
            {
                myshare = myshares[sender.tag]
                print("btn Rate Product\(myshare)")
                ref = FIRDatabase.database().reference()
                
                ref.child("User_Profiles").child(userID).child("MyLikes").child(myshare.path!).removeValue() { (error, ref) in
                    
                    if error != nil
                    {
                        print("error \(String(describing: error))")
                    }
                    else
                    {
                        self.getmyshinesdata()
                    }
                }
            }
        }
    }
    
    // Collectionview Datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
      print(badgescount)
     return badgescount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let badgesCollection: BadgesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "badgescell", for: indexPath) as! BadgesCollectionViewCell
        badgesCollection.Badgesimage.image = UIImage(named: Badgeimagesaarray[indexPath.item])
        return badgesCollection
    }
    
    func getbadgescount()-> Int
    {
        var count = Int()
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
        ref = FIRDatabase.database().reference()
        ref.child("User_Profiles").child(userID).child("Badges").observe(.value, with:  { (snapshot) in
            print(snapshot.childrenCount)
            
            DispatchQueue.main.async() {
                
            count  = Int(snapshot.childrenCount)
                if self.badgescount != nil
                {
                    self.lblBadges.text = "Badges : \(count)"
                    self.badgescount = count;
                }
            print(count)
                self.BadgesCOllections.reloadData()
            }
            self.hideHUD()
        })
        return count + 1
    }
    // Commentbuttontapped
    func commentbuttontapped(_ sender: UIButton)
    {
        let  btn = sender
        selectedindex = btn.tag
        self.performSegue(withIdentifier: "GotoCommentFromProfile", sender: self)
    }

        func getmysharesdata()
        {
            Utilities.sharedInstance.showHUD(view: self.view)
         let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
            ref = FIRDatabase.database().reference()
            ref.child("User_Profiles").child(userID).child("Myshares").observe(.value, with:  { (snapshot) in

                var share = [shareitem]()
                for id in snapshot.children
                {
                    let newshare = shareitem(snapshot: id as! FIRDataSnapshot)
                    share.insert(newshare, at: 0)
                    print(share)
                }
                self.myshares = share
                Utilities.sharedInstance.hideHUD(view: self.view)
                DispatchQueue.main.async(execute: {
                    self.ProfileTable.reloadData()
                })
            })
                
            { (error) in
                print(error.localizedDescription)
            }
    }
    
    func getmyshinesdata()
    {
        Utilities.sharedInstance.showHUD(view: self.view)        
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
        ref = FIRDatabase.database().reference()
        ref.child("User_Profiles").child(userID).child("MyLikes").observe(.value, with:  { (snapshot) in
            
            var share = [shareitem]()
            
            for id in snapshot.children
            {
                let newshare = shareitem(snapshot: id as! FIRDataSnapshot)
                share.insert(newshare, at: 0)
                print(share)
            }
            self.myshares = share
            Utilities.sharedInstance.hideHUD(view: self.view)
            DispatchQueue.main.async(execute: {
                self.ProfileTable.reloadData()
            })
        })
            
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    func displayUserdata()
    {
        ref = FIRDatabase.database().reference()
        
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
        ref.child("User_Profiles").child(userID).child("Badges").observe(.value, with:  { (snapshot) in
            print(snapshot.childrenCount)
            DispatchQueue.main.async()
                {
                self.badgescount = Int(snapshot.childrenCount)
                print(self.badgescount)
                if self.badgescount != nil
                {
                    self.lblBadges.text = "Badges : \(self.badgescount!)"
                }
            }
            self.hideHUD()
        })

        self.ref = FIRDatabase.database().reference()
        let query = self.ref.child("User_Profiles").queryOrdered(byChild: "id").queryEqual(toValue:userID)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let snap: FIRDataSnapshot? = snapshot else {
                print("No Reuslt Found")
                return
            }
            if snap?.value is NSNull
            {
                self.hideHUD()
                print("user not available")
            }
            else
            {
                let dict:Dictionary = snap?.value as! [String : AnyObject]
                let userId = Array(dict.keys)[0]
                let userInfo =  dict[userId]
                self.profilename.text = userInfo!["userName"]! as? String
                let rnk:String = (userInfo!["rank"] as? String)!
                self.rankCount = Int(rnk)
                
                if self.rankCount != nil
                {
                    self.lblRank.text = "Rank : \(self.rankCount!)"
                }
                
                if let profileImg : String = userInfo?["userProfilePic"] as? String
                {
                self.profileimage.sd_setImage(with: URL(string: profileImg ), placeholderImage: UIImage(named: "upload"))
                } else{
                    self.profileimage.image = UIImage(named: "upload")
                }
                
                self.hideHUD()
            }
        })
        
        ref = FIRDatabase.database().reference()
        ref.child("User_Profiles").child(userID).child("MyBadges").observe(.value, with:  { (snapshot) in
            
            var badges = [Inboxitem]()
            for id in snapshot.children
            {
                print("test")
            }
           
        })
        { (error) in
            print(error.localizedDescription)
        }
        
        
//        ref = FIRDatabase.database().reference()
//        ref.child("id").child(userData).observeSingleEvent(of: .value, with: {(snapshot) in
//            print(snapshot.value)
//            })
//                    self.ref.child("User_Profiles").child(userData).queryOrdered(byChild: "city").observeSingleEvent(of: .value, with: { snapshot in
//                        
//                        var statusvalue = ""
//                        if snapshot.value != nil {
//                            print(snapshot.key)
//                            statusvalue = snapshot.value as! String
//                        }
//                        else {
//                            print ("Detail not found")
//                        }
//                    })

        var user:NSDictionary
        //user = self.ref.child("User_Profiles").child(userData) as NSDictionary
        
       // self.profileimage.image = UIImage(named: "upload")
        //self.profilename.text = userData.object(forKey: "name") as? String
//        let filepath :String = userData.object(forKey: "profilePic") as! String
//        
//        do
//        {
//       self.profileimage.image = try UIImage(data: NSData(contentsOf: NSURL(string: filepath) as! URL) as Data)
//        }
//        catch
//        {
//        self.profileimage.image = UIImage(named: "upload")
//        }
//        FIRStorage.storage().reference(forURL: filepath ).data(withMaxSize: 10*1024*1024, completion: { (data, error) in
//                let imagedata = data
//                if imagedata != nil{
//                    //   if   let userPhoto = UIImage(data: (data)!){
//                    self.profileimage.image = UIImage(data: imagedata!)
//                }else {
//                    self.profileimage.image = UIImage(named: "upload")
//                }
//                
//            })
//            var userdetailsdefaults = UserDefaults.standard.set(userData.object(forKey: "name") as? String, forKey: "username")
//            userdetailsdefaults = UserDefaults.standard.set(userData.object(forKey: "profilePic") as? String, forKey: "userimage")
    }
    func likebuttonbuttonTapped(_ sender: UIButton)
    {
        let  btn = sender
        selectedindex = btn.tag
        
        var mytimeline = shareitem()
        mytimeline = self.myshares[selectedindex]
        
        var flag:Int = 0
        ref.child("Share").child("sharesall").child(mytimeline.key).child("likes").observeSingleEvent(of: .value, with:  { (snapshot) in
            
            for snap in snapshot.children
            {
                let snap1 = snap as! FIRDataSnapshot
                if (snap1.value as? Dictionary<String, AnyObject>) != nil
                {
                    if snap1.key == (FIRAuth.auth()!.currentUser?.uid)!
                    {
                        flag = 1;
                        self.ref.child("Share").child("sharesall").child(mytimeline.key).child("likes").child(snap1.key).removeValue()
                        let ref = FIRDatabase.database().reference().child("Share").child("sharesall").child(mytimeline.path!)
                        var likesCount:Int = (mytimeline.likesCount! as NSString).integerValue
                        likesCount -= 1
                        if likesCount < 0
                        {
                            likesCount = 0
                        }
                        ref.updateChildValues([
                            "likesCount": "\(likesCount)"
                            ])
                        
                        //self.getmysharesdata()
                        self.getmyshinesdata()
                        break
                    }
                }
            }
            
            if flag == 0
            {
                let commentinfo : Dictionary<String, Any> = ["category":"electronic",
                                                             "date": "test",
                                                             "name":"test",
                                                             "imgUrl":mytimeline.itemimage!,
                                                             "uid":(FIRAuth.auth()!.currentUser?.uid)!,]
                
                self.ref.child("Share").child("sharesall").child(mytimeline.key).child("likes").child((FIRAuth.auth()!.currentUser?.uid)!).setValue(commentinfo,withCompletionBlock: { (error, snapshot) in
                    
                    if error != nil {
                        print("oops, an error")
                    } else {
                        print("completed")
                        //self.getMyFavouriteData()
                        self.getmyshinesdata()
                    }
                })
                let ref = FIRDatabase.database().reference().child("Share").child("sharesall").child(mytimeline.path!)
                var likesCount:Int = (mytimeline.likesCount! as NSString).integerValue
                likesCount += 1
                if likesCount < 0
                {
                    likesCount = 0
                }
                ref.updateChildValues([
                    "likesCount": "\(likesCount)"
                    ])
            }
            else
            {
                
            }
        })
    }
//    {
//        let  btn = sender
//        selectedindex = btn.tag
//        let indexpaths: Int = selectedindex
//        let model = (myshares[indexpaths])
//        // let pathDB = model.path?
//        ref = FIRDatabase.database().reference()
//        ref.child("User_Profiles").child("Comments").child(model.key).child("Likes").runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
//            if var post = currentData.value as? [String : AnyObject], let uid = FIRAuth.auth()?.currentUser?.uid {
//                var stars: Dictionary<String, Bool>
//                stars = post["Like"] as? [String : Bool] ?? [:]
//                var starCount = post["LikesCount"] as? Int ?? 0
//                if let _ = stars[uid] {
//                    // Unstar the post and remove self from stars
//                    starCount -= 1
//                    stars.removeValue(forKey: uid)
//                } else {
//                    // Star the post and add self to stars
//                    starCount += 1
//                    stars[uid] = true
//                }
//                post["LikesCount"] = starCount as AnyObject?
//                post["Likes"] = stars  as AnyObject?
//                
//                // Set value and report transaction success
//                currentData.value = post
//                
//                return FIRTransactionResult.success(withValue: currentData)
//            }
//            return FIRTransactionResult.success(withValue: currentData)
//        }) { (error, committed, snapshot) in
//            if let error = error {
//                print(error.localizedDescription)
//            }
//        }
//    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GotoCommentFromProfile"{
            let indexpaths = selectedindex
            let model = myshares[indexpaths!]
            let CommentVC: CommentsViewController = segue.destination as! CommentsViewController
            CommentVC.pathid = model.path!
        }

    }
}
extension UIView {
    
    func slideInFromLeft(duration: TimeInterval = 0.5, completionDelegate: AnyObject? = nil) {
        // Create a CATransition animation
        let slideInFromLeftTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: CAAnimationDelegate = completionDelegate as! CAAnimationDelegate? {
            slideInFromLeftTransition.delegate = delegate
        }
        
        // Customize the animation's properties
        slideInFromLeftTransition.type = kCATransitionPush
        slideInFromLeftTransition.subtype = kCATransitionFromLeft
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromLeftTransition.fillMode = kCAFillModeRemoved
        
        // Add the animation to the View's layer
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
    }
    func slideInFromRight(duration: TimeInterval = 0.5, completionDelegate: AnyObject? = nil) {
        // Create a CATransition animation
        let slideInFromLeftTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: CAAnimationDelegate = completionDelegate as! CAAnimationDelegate? {
            slideInFromLeftTransition.delegate = delegate
        }
        
        // Customize the animation's properties
        slideInFromLeftTransition.type = kCATransitionPush
        slideInFromLeftTransition.subtype = kCATransitionFromRight
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromLeftTransition.fillMode = kCAFillModeRemoved
        
        // Add the animation to the View's layer
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
    }

}


