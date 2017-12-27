//
//  TimeLineViewController.swift
//  HereYaGo
//
//  Created by DawnShine on 14/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import MapKit

let ktitle = "title"
let kdescription = "description"
let kcategory = "category"

class Station: NSObject, MKAnnotation {
    
    var title: String?
    var subtitle: String?
    var latitude: Double
    var longitude:Double
    var tagForAnnotation:Int = 0
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

class TimeLineViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate , UITextFieldDelegate, UIActionSheetDelegate, UISearchBarDelegate, MKMapViewDelegate
{
    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet var AllShareBtn: UIButton!
    @IBOutlet var NearByBtn: UIButton!
    var searchActive : Bool = false

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imageProduct: UIImageView!
    @IBOutlet var sharebutton: UIBarButtonItem!
    @IBOutlet var displayview: UIView!
    @IBOutlet var TimeLineTable: UITableView!
    @IBOutlet var searchBarButtonItem: UIBarButtonItem!
    var searchBar = UISearchBar()
    
    @IBOutlet weak var buttonContainerView: UIView!
    //let mapView = MKMapView()
    var ref = FIRDatabase.database().reference()
    var storageref = FIRStorageReference()
    var timelineitems:Array = [shareitem]()
    var nearbitems :Array = [nearbyitem]()
    var seachTimelineitems:Array = [shareitem]()
    var selectedindex: Int!
    
    var myFavourates = [shareitem]()
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.getMyFavouriteData()
        
       // NSLog("%d", 4)
        if revealViewController() != nil {
            //            revealViewController().rearViewRevealWidth = 62
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            revealViewController().rightViewRevealWidth = 150
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
              Utilities.sharedInstance.hideHUD(view: self.view)
        }
        self.gettimelinedata()
        // self.sharebutton.addTarget(self, action: #selector(self.commentbuttontapped), for: .touchUpInside)
        searchBar.delegate = self
        searchBar.searchBarStyle = UISearchBarStyle.minimal
        searchBarButtonItem = navigationItem.rightBarButtonItem
        searchBar.returnKeyType = .done;
        self.mapView.isHidden = true
        
        imagePicker.delegate = self
                
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(sender:)));
        upSwipe.direction = .left
        self.view.addGestureRecognizer(upSwipe)
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer)
    {
        if (sender.direction == .left)
        {
            if ( UIImagePickerController.isSourceTypeAvailable(.photoLibrary))
            {
               // if UIImagePickerController.availableCaptureModes(for: .rear) != nil
                //{
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.cameraCaptureMode = .photo
                    present(imagePicker,animated: true, completion: {})
               // }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool)
    {
        self.getMyFavouriteData()
         self.gettimelinedata()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func menubuttontapped(_ sender: Any)
    {
        if revealViewController() != nil
        {
            // revealViewController().rearViewRevealWidth = 62
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rightViewRevealWidth = 150
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    @IBAction func segmentbutttonaction(_ sender: UIButton)
    {
        let selected = sender.tag
        switch selected {
        case 100:
           self.mapView.isHidden = true
            self.gettimelinedata()
           UIView.animate(withDuration: 0.5, animations: {
           // self.changeLbl.frame = CGRect(x: self.MyShareBtn.frame.origin.x, y: self.changeLbl.frame.origin.y, width: self.MyShareBtn.frame.size.width, height: self.changeLbl.frame.size.height )
            self.AllShareBtn.backgroundColor = UIColor.init(colorLiteralRed: 5.0/255.0, green: 46.0/255.0, blue: 89.0/255.0, alpha: 1)
            self.NearByBtn.backgroundColor = UIColor.init(colorLiteralRed: 9.0/255.0, green: 71.0/255.0, blue: 138.0/255.0, alpha: 1)
            
           })

            break
        case 200:
            
            self.mapView.isHidden = false
            self.showmapview()
            self.getNearByData()
            self.zoomToRegion()

            UIView.animate(withDuration: 0.5, animations: {
                
                self.NearByBtn.backgroundColor = UIColor.init(colorLiteralRed: 5.0/255.0, green: 46.0/255.0, blue: 89.0/255.0, alpha: 1)
                self.AllShareBtn.backgroundColor = UIColor.init(colorLiteralRed: 9.0/255.0, green: 71.0/255.0, blue: 138.0/255.0, alpha: 1)
            })
            break
        
        default:
             self.mapView.isHidden = true
            self.gettimelinedata()
            UIView.animate(withDuration: 0.5, animations: {
                self.AllShareBtn.backgroundColor = UIColor.init(colorLiteralRed: 5.0/255.0, green: 46.0/255.0, blue: 89.0/255.0, alpha: 1)
                self.NearByBtn.backgroundColor = UIColor.init(colorLiteralRed: 9.0/255.0, green: 71.0/255.0, blue: 138.0/255.0, alpha: 1)
                
            })
            break
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if((searchBar.text?.characters.count)! > 0)
        {
            return self.seachTimelineitems.count;
        }
        else
        {
            return self.timelineitems.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print("hello")
        selectedindex = indexPath.row
        self.performSegue(withIdentifier: "GotoShareDetails", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let timelineCell : TimeLineCell = TimeLineTable.dequeueReusableCell(withIdentifier: "timelinecells", for: indexPath) as! TimeLineCell
        
        var mytimeline = shareitem()
        if((searchBar.text?.characters.count)! > 0)
        {
            mytimeline = seachTimelineitems[indexPath.row]
        }
        else
        {
            mytimeline = timelineitems[indexPath.row]
        }
        timelineCell.btnComment.tag = indexPath.row
        timelineCell.btnLike.tag = indexPath.row
        timelineCell.btnRateProduct.tag = indexPath.row
        timelineCell.btnTopShare.tag = indexPath.row
        timelineCell.btnImgProduct.tag = indexPath.row
        timelineCell.lblProductName.text = mytimeline.itemtitle
        timelineCell.lbldate.text = mytimeline.postdate
        timelineCell.lblProductDescription.text = mytimeline.itemdes
        timelineCell.userID = mytimeline.userid
        timelineCell.lblMemberName.text = mytimeline.itemusername
        //timelineCell.lblMemberDetails.text = String.init(format: "%@Badges, Rank:%@", mytimeline.userBadge!,mytimeline.userRank!)
        timelineCell.pathDB = mytimeline.key
        
        
        if  !(mytimeline.itemuserimage!.isEmpty)
        {
          timelineCell.imgMember.sd_setImage(with: URL(string: mytimeline.itemuserimage!), placeholderImage: UIImage(named: "upload"))
        }
        else
        {
            timelineCell.imgMember.image = UIImage(named :"upload")
        }
        
        if  !(mytimeline.itemimage!.isEmpty)
        {
           timelineCell.imageProduct.sd_setImage(with: URL(string: mytimeline.itemimage!), placeholderImage: UIImage(named: "login-bg"))
            timelineCell.btnImgProduct.isHidden = true
            
        } else{
            timelineCell.btnImgProduct.setImage(UIImage(named: "login-bg"), for: .normal)
        }
        
        var lks : String! = mytimeline.likesForPost;
        lks = lks+" likes"
        timelineCell.lblLikesCount.text = "\(mytimeline.likesCount!) Likes"
        
        var pts : Int = mytimeline.userPoints
        //timelineCell.lblPoints.text! = String(format: "%d Points",pts)
        let userID =  mytimeline.key!
        
        
        let query = ref.child("User_Profiles").queryOrdered(byChild: "id").queryEqual(toValue: userID)
        
        query.observeSingleEvent(of: .value, with: { (dbSnapshot) in
            
            guard let snap: FIRDataSnapshot? = dbSnapshot else {
                print("No Reuslt Found")
                return
            }
            if snap?.value is NSNull
            {
               print("test")
            }
            else
            {
                print("success")

            }
        })
        {  (error) in
            print("test error")
        }
        
//        self.ref = FIRDatabase.database().reference()
//        self.ref.child("User_Profiles").child(userID).child("Points").observe(.value, with:  { (snapshot) in
//            
//            guard let snap: FIRDataSnapshot? = snapshot else {
//                print("No Reuslt Found")
//                return
//            }
//            if snap?.value is NSNull
//            {
//                self.showAlertView(withTitle: "User Not registered")
//            }
//            else
//            {
//                pts = Int(snapshot.value as! Int)
//                
//                timelineCell.lblPoints.text = String(format : "%d Points",pts)
//                //                        DispatchQueue.main.async()
//                //                            {
//                //                                self.points = Int(snapshot.value as! Int)
//                //                                print(self.points)
//                //                                self.userRankLabel.text = String(format : "You are at rank %i with %i points",self.rank,self.points)
//                //                        }
//            }
//        })
//        
        var coments : String  = mytimeline.commentsCount
       // coments = coments + "Comments"
       // timelineCell.lblComments.text! = coments
        
        //OR
        
        ref = FIRDatabase.database().reference()
        ref.child("Share").child("sharesall").child(mytimeline.key).child("comments").observe(.value, with:  { (snapshot) in
            
            var share = [commentitem]()
            
            for id in snapshot.children {
                
                let newshare = commentitem(snapshot: id as! FIRDataSnapshot)
                
                share.insert(newshare, at: 0)
                print(share)
            }
            //self.commentdata = share
            let count = share.count
            timelineCell.lblComments.text! = "\(count)Comments"
        })

        timelineCell.btnLike.addTarget(self, action: #selector(self.likebuttonbuttonTapped), for: .touchUpInside)
        
        timelineCell.btnComment.addTarget(self, action: #selector(self.commentbuttontapped), for: .touchUpInside)
        
        timelineCell.btnRateProduct.addTarget(self, action: #selector(self.favouritebuttontapped), for: .touchUpInside)
        timelineCell.btnTopShare.addTarget(self, action: #selector(self.topsharebtnshared), for: .touchUpInside)
        timelineCell.btnImgProduct.addTarget(self, action: #selector(self.imageproducttapped), for: .touchUpInside)
        timelineCell.selectionStyle = .none
        
        if (self.isFavourateItem(timelineItem: mytimeline) >= 0)
        {
            timelineCell.btnRateProduct.setImage(UIImage.init(named:"points_filled"), for: UIControlState.normal)
         }
         else
         {
            timelineCell.btnRateProduct.setImage(UIImage.init(named:"points"), for: UIControlState.normal)
         }

        let likeCount:Int = isThisShareIsLikedByMe(timelineitem: mytimeline)
        if (likeCount == 1)
        {
            timelineCell.lblLikesCount.textColor = UIColor.green
        }
        else
        {
            timelineCell.lblLikesCount.textColor = UIColor.gray
        }
        return timelineCell
    }

    func imageproducttapped(_ sender: UIButton)
    {
        let  btn = sender
        selectedindex = btn.tag
        self.performSegue(withIdentifier: "GotoShareDetails", sender: self)
    }
    
    @IBAction func sharebuttontapped(_ sender: Any)
    {
        let sharevc : ShareformViewController = (self.storyboard?.instantiateViewController(withIdentifier: "ShareformViewController"))! as! ShareformViewController
        sharevc.isFromTimeLine = true
        self.navigationController?.pushViewController(sharevc, animated: true)
       //self.performSegue(withIdentifier: "GotoShareformfromTopShare", sender: self)
     }
    
    func addToMyFavourateItem(SelectedIndex:Int)
    {
        let model = timelineitems[selectedindex]
        let favouriteinfo = ["title": model.itemtitle,
                             "imgUrl": model.itemimage,
                             "uid" : model.userid,
                             "date": model.postdate,
                             "strescription": model.itemdes,
                             "category":model.itemcategory,
                             "productKey":model.key!,
                             "strDescription":model.itemdes,
                             "numDays":model.numOfDays,
                             ]
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
        ref = FIRDatabase.database().reference()
        ref.child("User_Profiles").child(userID).child("MyLikes").child(model.path!).setValue(favouriteinfo,
                                                                                                                           withCompletionBlock: { (error, snapshot) in
                                                                                                                            if error != nil {
                                                                                                                                Utilities.sharedInstance.hideHUD(view: self.view)
                                                                                                                                print("oops, an error")
                                                                                                                            } else {
                                                                                                                                
                                                                                                                                self.getMyFavouriteData()
                                                                                                                                self.gettimelinedata()
                                                                                                                                print("completed")
                                                                                                                            }
        })
    }
    func removeFromMyFavourates(favourate:shareitem)
    {
        // delete post from my favourites
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
        self.ref = FIRDatabase.database().reference()
        self.ref.child("User_Profiles").child(userID).child("MyLikes").child(favourate.path!).removeValue() { (error, ref) in
            
            if error != nil
            {
                Utilities.sharedInstance.hideHUD(view: self.view)
                print("error \(String(describing: error))")
            }
            else
            {
                self.getMyFavouriteData()
                self.gettimelinedata()
            }
        }
    }
    
    func isFavourateItem(timelineItem:shareitem) -> Int
    {
        var flag:Int = -1
        for index in 0 ..< self.myFavourates.count
        {
            let favourate:shareitem = self.myFavourates[index]
            if favourate.productKey! == timelineItem.key
            {
                flag = index
                break
            }
        }
        return flag
    }
    
   // Favouritebuttontapped
    func favouritebuttontapped(_ sender: UIButton)
    {
        Utilities.sharedInstance.showHUD(view: self.view)
        let  btn = sender
        selectedindex = btn.tag
        
        var selectedTimeline = shareitem()
        selectedTimeline = timelineitems[selectedindex]
        let index:Int = isFavourateItem(timelineItem: selectedTimeline)

        if (index >= 0)
        {
            let favourate:shareitem = self.myFavourates[index]
            self.removeFromMyFavourates(favourate: favourate)
        }
        else
        {
            self.addToMyFavourateItem(SelectedIndex: selectedindex)
        }
    }
    
    func  topsharebtnshared(_ sender: UIButton)
    {
        let  btn = sender
        selectedindex = btn.tag
        
        var mytimeline = shareitem()
        
        if((searchBar.text?.characters.count)! > 0)
        {
            mytimeline = seachTimelineitems[selectedindex]
        }
        else
        {
            mytimeline = timelineitems[selectedindex]
        }
        
        let sharevc : requestFormViewController = (self.storyboard?.instantiateViewController(withIdentifier: "requestFormViewController"))! as! requestFormViewController
        sharevc.productData = mytimeline
        self.navigationController?.pushViewController(sharevc, animated: true)
      //  self.performSegue(withIdentifier: "GotoShareformfromTopShare", sender: self)
    }
    
// Commentbuttontapped
    func commentbuttontapped(_ sender: UIButton)
    {
        let  btn = sender
        selectedindex = btn.tag
        self.performSegue(withIdentifier: "GotoShareDetails", sender: self)
    }
// likebuttontapped:
    
    func getikecount(productpath: String)-> Int{
        var count = Int()
        ref = FIRDatabase.database().reference()
        ref.child("Share").child("sharesall").child("Electronics").child(productpath).child("likes").observe(.value, with:  { (snapshot) in
              print(snapshot.childrenCount)
              count = Int(snapshot.childrenCount)
        })
        return count
    }
    
    func isThisShareIsLikedByMe(timelineitem:shareitem) -> Int
    {
        var flag :Int = -1
        ref = FIRDatabase.database().reference()
        var index :Int = -1
        ref.child("Share").child("sharesall").child(timelineitem.key).child("likes").observe(.value, with:  { (snapshot) in
            
            for snap in snapshot.children
            {
                if let postDict = (snap as! FIRDataSnapshot ).value as? Dictionary<String, AnyObject>
                {
                    flag = 1
                    
                }
            }
        })
        return flag;
        
//        ref.child("Share").child("sharesall").child(timelineitem.productKey).child("likes").observe(.value, with:  { (snapshot) in
//            
//            guard let snap: FIRDataSnapshot? = snapshot else {
//                print("No Reuslt Found")
//                return
//            }
//
//            var index :Int = -1
//            for id in snapshot.children
//            {
//                index = index + 1
//                let newshare = shareitem(snapshot: id as! FIRDataSnapshot)
//                if newshare.userid == (FIRAuth.auth()!.currentUser?.uid)!
//                {
//                    flag = index
//                    break
//                }
//                print(timelineitem)
//            }
//        })
//        { (error) in
//            print(error.localizedDescription)
//        }
//        return flag
    }
    
    func likebuttonbuttonTapped(_ sender: UIButton)
    {
        let  btn = sender
        selectedindex = btn.tag
        
        var mytimeline = shareitem()
        mytimeline = timelineitems[selectedindex]
        
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
                        
                        self.gettimelinedata()
                        self.getNearByData()
                        break
                    }
                }
            }
            
            if flag == 0
            {
                  let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
                let commentinfo : Dictionary<String, Any> = ["category":"electronic",
                                                             "date": "test",
                                                             "name":"test",
                                                             "imgUrl":mytimeline.itemimage!,
                                                             "uid":userID,]
                
                self.ref.child("Share").child("sharesall").child(mytimeline.key).child("likes").child(userID).setValue(commentinfo,withCompletionBlock: { (error, snapshot) in
                    
                    if error != nil {
                        print("oops, an error")
                    } else {
                        print("completed")
                        self.getMyFavouriteData()
                        self.gettimelinedata()
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
    
    func gettimelinedata()
    {
        //  let userID = FIRAuth.auth()?.currentUser?.uid
        ref = FIRDatabase.database().reference()
        ref.child("Share").child("sharesall").observe(.value, with:  { (snapshot) in
            
            var timelineitem = [shareitem]()
            for id in snapshot.children
            {
                let newshare = shareitem(snapshot: id as! FIRDataSnapshot)
                timelineitem.insert(newshare, at: 0)
                print(timelineitem)
            }
            self.timelineitems = timelineitem
            DispatchQueue.main.async(execute:
            {
                self.TimeLineTable.reloadData()
                Utilities.sharedInstance.hideHUD(view: self.view)
            })
        })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getMyFavouriteData()
    {
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
            self.myFavourates = share
        })
            
        { (error) in
            print(error.localizedDescription)
        }
    }

    func getNearByData()
    {
        //  let userID = FIRAuth.auth()?.currentUser?.uid
        ref = FIRDatabase.database().reference()
        ref.child("User_Profiles").observe(.value, with:  { (snapshot) in
            
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
                print(dict)
                
                var nearbyItems = [nearbyitem]()
                for id in snapshot.children
                {
                    let newNearBy = nearbyitem(snapshot: id as! FIRDataSnapshot)
                    nearbyItems.insert(newNearBy, at: 0)
                    print(newNearBy)
                }
                self.nearbitems = nearbyItems
                self.zoomToRegion()
            }
        })
        { (error) in
            print(error.localizedDescription)
        }
    }

    // Searchbaritem:
    @IBAction func searchaction(_ sender: Any)
    {
        self.showSearchBar()
    }
    
    func showSearchBar()
    {
        searchBar.alpha = 0
        navigationItem.titleView = searchBar
        searchBar.showsCancelButton = true;
        navigationItem.setLeftBarButton(nil, animated: true)
        UIView.animate(withDuration: 0.5, animations: {
            self.searchBar.alpha = 1
        }, completion: { finished in
            self.searchBar.becomeFirstResponder()
        })
        searchBar.isHidden = false;
    }
    
    func hideSearchBar()
    {
        navigationItem.setLeftBarButton(menuButton, animated: true)
       // self.navigationItem.titleView?.removeFromSuperview();
        self.navigationItem.titleView = nil
        
        UIView.animate(withDuration: 0.3, animations: {
         //   self.navigationItem.titleView = self.logoImageView
            //self.logoImageView.alpha = 1
        }, completion: { finished in

        })
    }
    
    //MARK:-  UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        hideSearchBar()
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.isHidden = true;
        TimeLineTable.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
         searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        searchActive = false;
       searchBar.resignFirstResponder()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        
         searchActive = false;
         searchBar.resignFirstResponder()
         return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchActive = false;
         searchBar.resignFirstResponder()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar)
    {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        let trimmedString = searchText.trimmingCharacters(in: .whitespacesAndNewlines) 
        seachTimelineitems.removeAll()
        if trimmedString.characters.count > 0
        {
            for timelineitemsArray in timelineitems
            {
                let searchString = String(format : "%@ %@",timelineitemsArray.itemdes!,timelineitemsArray.itemtitle!)
                if searchString.lowercased().range(of: trimmedString.lowercased()) != nil
                {
                    seachTimelineitems.append(timelineitemsArray)
                }
            }
        }
        else
        {
            for timelineitemsArray in timelineitems
            {
                    seachTimelineitems.append(timelineitemsArray)
            }
        }
        TimeLineTable.reloadData()
    }

    // MARK:- Custom methods
    func getsearchdatafromdb()
    {
        //  let userID = FIRAuth.auth()?.currentUser?.uid
        ref = FIRDatabase.database().reference()
        ref.child("Share").child("sharesall").child("Electronics").queryOrdered(byChild: "category").queryEqual(toValue: self.searchBar.text).observe(.value, with:  { (snapshot) in
            
            var searchitem = [shareitem]()
            
            for id in snapshot.children
            {
                let newshare = shareitem(snapshot: id as! FIRDataSnapshot)
                searchitem.insert(newshare, at: 0)
                print(searchitem)
            }
            //self.timelineitems = searchitem
            DispatchQueue.main.async(execute: {
                self.TimeLineTable.reloadData()
            })
        })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    func addKeyboardButton()
    {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        keyboardToolbar.isTranslucent = false
        keyboardToolbar.barTintColor = UIColor.blue
        
        let addButton = UIButton(type: .custom)
        addButton.frame = CGRect(x: keyboardToolbar.frame.size.width / 2, y: keyboardToolbar.frame.size.height / 2, width: 50, height: 30)
        addButton.addTarget(self, action: #selector(getsearchdatafromdb), for: .touchUpInside)
        let item = UIBarButtonItem(customView: addButton)
        keyboardToolbar.items = [item]
        
        self.searchBar.inputAccessoryView = keyboardToolbar
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
        if segue.identifier == "GotoShareDetails"
        {
          //  let indexpaths = selectedindex
           // let model = timelineitems[selectedindex]
            var mytimeline = shareitem()
            
            mytimeline = timelineitems[selectedindex!]
            
            let sharedetailvc: ShareDetailsViewController = segue.destination as! ShareDetailsViewController
            sharedetailvc.productData = mytimeline
        }
        if segue.identifier == "GotoShareformfromTopShare"
        {
            if selectedindex != nil
            {
                let model = timelineitems[selectedindex!]
                let shareinfoDict:[String : String] = [ktitle : model.itemtitle!, kdescription: model.itemdes!, kcategory: model.itemcategory!]
                let sharevc: ShareformViewController = segue.destination as! ShareformViewController
                
                sharevc.isFromTimeLine = true
                sharevc.previewDict = shareinfoDict
            }
            else
            {
                let sharevc: ShareformViewController = segue.destination as! ShareformViewController
                
                sharevc.isFromTimeLine = true
            }
        }
        if segue.identifier == "GoToCommentFromTimeline"
        {
            let indexpaths = selectedindex
            let model = timelineitems[indexpaths!]
            let CommentVC: CommentsViewController = segue.destination as! CommentsViewController
            CommentVC.pathid = model.path!
        }
        
        if segue.identifier == "GotoShareform"
        {
            
        }
    }
    
    func zoomToRegion()
    {
        self.mapView.delegate = self
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations);
        for  i:Int in 0 ..< nearbitems.count
        {
            var nearbyByItem = nearbyitem()
            nearbyByItem = self.nearbitems[i]
            
            if nearbyByItem.latitude != nil && nearbyByItem.longitude != nil
            {
                let lat:Float = (nearbyByItem.latitude as NSString).floatValue
                let long:Float = (nearbyByItem.longitude as NSString).floatValue

                let annotation = Station(latitude: Double(lat), longitude:Double(long))
                annotation.title = nearbyByItem.itemusername
                
                let location = CLLocationCoordinate2D(latitude:CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
                let region = MKCoordinateRegionMakeWithDistance(location, 3000.0, 3000.0)
                
                for  i:Int in 0 ..< timelineitems.count
                {
                    var timeLineItem = shareitem()
                    timeLineItem = self.timelineitems[i]
                    if timeLineItem.userid == nearbyByItem.userid
                    {
                        annotation.tagForAnnotation = i
                        self.mapView.addAnnotation(annotation)
                        break;
                    }
                }
                self.mapView.setRegion(region, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        
        if annotation is MKUserLocation
        {
            return nil
        }
        else {
            var tag: Int = 0
            var nearbyByItem:shareitem? = nil
            if annotation.isKind(of:Station.self) && self.timelineitems.count > tag
            {
                let annotation:Station = annotation as! Station
                tag = annotation.tagForAnnotation
                nearbyByItem = shareitem()
                nearbyByItem = self.timelineitems[tag]
            }
            
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
            annotationView.image = UIImage(named: "menu")
            annotationView.backgroundColor = UIColor.red
            annotationView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            annotationView.tag = 5
            let imageview = UIImageView(frame: CGRect(x: 0, y: 0, width: 350, height: 350))
            annotationView.canShowCallout = true
            imageview.image = UIImage(named: "Location");
           //annotationView.rightCalloutAccessoryView = imageview
            configureDetailView(annotationView: annotationView,tag:tag)
            //annotationView.detailCalloutAccessoryView =
            return annotationView
        }
    }
    
    func configureDetailView(annotationView: MKAnnotationView,tag:Int)
    {
        let shareItem:shareitem? = self.timelineitems[tag]
        let width = 300
        let height = 300
        let snapshotView = UIView()
        let views = ["snapshotView": snapshotView]
        snapshotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[snapshotView(350)]", options: [], metrics: nil, views: views))
        snapshotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[snapshotView(350)]", options: [], metrics: nil, views: views))
        
        let options = MKMapSnapshotOptions()
        options.size = CGSize(width: width, height: height)
        options.mapType = .satelliteFlyover
       // options.camera = MKMapCamera(lookingAtCenterCoordinate: annotationView.annotation!.coordinate, fromDistance: 250, pitch: 65, heading: 0)
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            if snapshot != nil {
               // let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
                //let indxPath:IndexPath = IndexPath(row: 0, section: 0)
                
                //let cell : TimeLineCell = self.TimeLineTable .cellForRow(at:indxPath) as! TimeLineCell
                
                //cell.frame = CGRect(x: 0, y: 0, width: snapshotView.frame.size.width, height: snapshotView.frame.size.height)
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
                tap.delegate = self as? UIGestureRecognizerDelegate
                
                let subView : AnnotationDetails = AnnotationDetails.instanceFromNib()
                subView.tag = tag
                
                var lks : String! = shareItem!.likesForPost;
                lks = lks+" likes"
                subView.lblLikesCount.text = lks!
                
                var pts : Int = shareItem!.userPoints
                subView.lblPoints.text! = String(format : "%d Points",pts)

                subView.lblUserName.text = shareItem?.itemusername
                var coments : String  = shareItem!.commentsCount
                coments = coments + "Comments"
                subView.lblComments.text! = coments

                if  !((shareItem?.itemimage!.isEmpty)!)
                {
                    subView.imageProduct.sd_setImage(with: URL(string: (shareItem?.itemimage!)!), placeholderImage: UIImage(named: "login-bg"))
                } else{
//                    subView.imageProduct.setImage(UIImage(named: "login-bg"), for: .normal)
                }
                subView.addGestureRecognizer(tap)
                subView.frame = snapshotView.frame
                snapshotView.addSubview(subView)
            }
        }
        annotationView.detailCalloutAccessoryView = snapshotView
    }

    func handleTap(sender: UITapGestureRecognizer? = nil)
    {
        // handling code
       let subView : AnnotationDetails = sender?.view as! AnnotationDetails
        selectedindex = subView.tag
        self.performSegue(withIdentifier: "GotoShareDetails", sender: self)
    }
    
    // Show map:
     func showmapview()
     {
        mapView.frame = CGRect(x:0, y: -50, width:self.view.frame.size.width, height:self.displayview.frame.size.height)
        //CGRect(0,self.buttonContainerView.frame.origin.y+self.buttonContainerView.frame.size.height,self.view.frame.size.width,self.view.frame.size.height); //self.displayview.frame
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.center = view.center
        //displayview.addSubview(mapView)
        //self.addAnotatation()
    }
    
    func addAnotatation()
    {
        self.mapView.delegate = self
        let location = CLLocationCoordinate2D(latitude: 18.520, longitude: 73.8567)
        let region = MKCoordinateRegionMakeWithDistance(location, 3000.0, 3000.0)
        self.mapView.setRegion(region, animated: true)
        let annotation = Station(latitude: 12.4, longitude: 17.0)
        //annotation.title = "ano Title"
        self.mapView.addAnnotation(annotation)
    }
}
