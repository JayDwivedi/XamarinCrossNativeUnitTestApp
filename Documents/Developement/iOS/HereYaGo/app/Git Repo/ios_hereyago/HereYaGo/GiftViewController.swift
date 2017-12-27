
//  GiftViewController.swift
//  HereYaGo
//
//  Created by DawnShine on 15/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class GiftViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet var GiftTable: UITableView!
    var Gifts = [Giftsitem]()
    var ref = FIRDatabaseReference()
    var storageref = FIRStorageReference()
    
    @IBOutlet weak var rewardsLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        if revealViewController() != nil {
            //            revealViewController().rearViewRevealWidth = 62
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            revealViewController().rightViewRevealWidth = 150
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.getgiftsdatafromBD()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            self.rewardsLabel.text = String(format : "You earned a total of %@ with %@ shares till now.","$3","4")  //  text π®å∂ˆπ
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.Gifts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let timelineCell : GiftCell = GiftTable.dequeueReusableCell(withIdentifier: "giftcells", for: indexPath) as! GiftCell
        var mygift = Giftsitem()
        mygift = Gifts[indexPath.row]
        timelineCell.lblMemberName.text = mygift.gifttitle
        timelineCell.startDate.text = mygift.date!
        timelineCell.lblMemberValueGift.text = (mygift.giftvalue!)
        timelineCell.couponCodeLabel.text = mygift.couponCode;
        
        timelineCell.imgMember.layer.cornerRadius = timelineCell.imgMember.frame.size.width/2;
        if let itemimg = mygift.giftimage{
            
            timelineCell.imgMember.sd_setImage(with: URL(string: itemimg), placeholderImage: UIImage(named: "login-bg"))
          /*  storageref = FIRStorage.storage().reference(forURL: itemimg)
            
            self.storageref.data(withMaxSize: 10*1024*1024, completion: { (data, error) in
                
                let userPhoto = UIImage(data: (data)!)
                timelineCell.imgMember.image = userPhoto
            })  */
        } else{
            timelineCell.imgMember.image = UIImage(named: "login-bg")
        }
        
        return timelineCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let url = NSURL.init(string: "https://www.google.co.in")
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url as! URL, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
        }

       

    }
    
    func getgiftsdatafromBD(){
        
        Utilities.sharedInstance.showHUD(view: self.view)
        
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
        ref = FIRDatabase.database().reference()
        
//        let query = ref.child("GiftCoupons").queryOrdered(byChild: "uid").queryEqual(toValue: userID)
      //  let query = ref.child("GiftCoupons").queryOrdered(byChild: "uid").queryEqual(toValue: userID)
      //  query.observeSingleEvent(of: .value, with: { (snapshot) in
            
        ref.child("GiftCoupons").observeSingleEvent(of: .value, with:  { (snapshot) in
            
            var Gitem = [Giftsitem]()
            for id in snapshot.children {
                let newgift = Giftsitem(snapshot: id as! FIRDataSnapshot)
                Gitem.insert(newgift, at: 0)
                print(Gitem)
            }
            self.Gifts = Gitem
            DispatchQueue.main.async(execute: {
                self.GiftTable.reloadData()
                Utilities.sharedInstance.hideHUD(view: self.view)
            })
        })
        { (error) in
            print(error.localizedDescription)
            Utilities.sharedInstance.hideHUD(view: self.view)
        }
    }
}
