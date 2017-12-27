
//
//  LeaderboardViewController.swift
//  HereYaGo
//
//  Created by DawnShine on 17/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class LeaderboardViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet var menuButton: UIBarButtonItem!
    
    @IBOutlet var LeaderboardTable: UITableView!
    
    @IBOutlet weak var userRankLabel: UILabel!
    
    var ref : FIRDatabaseReference!
    var storageref = FIRStorageReference()
    var leaderboarditems = [Usersdetails]()
    var points : Int = 0;
    var rank  : Int = 0
    var shareCount : Int = 0;


    
    override func viewDidLoad() {
        super.viewDidLoad()
        if revealViewController() != nil {
            //            revealViewController().rearViewRevealWidth = 62
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            revealViewController().rightViewRevealWidth = 150
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
       // You are at rank 18 with 1400 points.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func getPoints()-> Int
    {
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
       
        ref = FIRDatabase.database().reference()
        ref.child("User_Profiles").child(userID).child("Points").observe(.value, with:  { (snapshot) in
            
            print(snapshot.value ?? 0)
            if(snapshot.value != nil)
            {
            self.points = Int(snapshot.value as! Int)
              
            DispatchQueue.main.async()
            {
                self.points = Int(snapshot.value as! Int)
                print(self.points)
            self.userRankLabel.text = String(format : "You are at rank %i with %i points",self.rank,self.points)
            }
            }
        })
        print(points)
        
        return points
    }
    
    func getRanks()-> Int
    {
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
        ref = FIRDatabase.database().reference()
        ref.child("User_Profiles").child(userID).child("rank").observe(.value, with:  { (snapshot) in
            print(snapshot.childrenCount)
            DispatchQueue.main.async() {
                self.rank = Int(snapshot.childrenCount)
                print(self.rank)
            }
        })
               print(rank)
            return rank
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.leaderboarditems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
         let leadercell: LeaderboardCell = LeaderboardTable.dequeueReusableCell(withIdentifier: "leadercells", for: indexPath) as! LeaderboardCell
        
        return leadercell
    }
    
    
    func getmysharesdata()-> Int
    {
        var shareCount = Int()
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
        ref = FIRDatabase.database().reference()
        ref.child("User_Profiles").child(userID).child("Myshares").observe(.value, with:  { (snapshot) in
            let share = [shareitem]()
            shareCount = Int(snapshot.childrenCount);
        })
        
        return shareCount;
    }
    
    func getbadgescount()-> Int
    {
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
        var count = Int()
        ref = FIRDatabase.database().reference()
        ref.child("User_Profiles").child(userID).child("Badges").observe(.value, with:  { (snapshot) in
            print(snapshot.childrenCount)
           
            count = Int(snapshot.childrenCount);
        })
        return count;
    }
    
   
    
    
}
