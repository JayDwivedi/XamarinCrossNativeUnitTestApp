//
//  InboxViewController.swift
//  HereYaGo
//
//  Created by Dawn on 24/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class InboxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{

    @IBOutlet var Inboxtable: UITableView!
    var ref: FIRDatabaseReference!
    var storageref : FIRStorageReference!
    var inboxdata = [Inboxitem]()
    @IBOutlet var menuButton: UIBarButtonItem!
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.getinboxdata()
        // Do any additional setup after loading the view.
        Inboxtable.rowHeight = UITableViewAutomaticDimension
        Inboxtable.estimatedRowHeight = 65
        self.Inboxtable.tableFooterView = UIView()

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.inboxdata.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let inboxcell: InboxTableViewCell = tableView.dequeueReusableCell(withIdentifier: "inboxcell") as! InboxTableViewCell
        ref = FIRDatabase.database().reference()
        var myInbox = Inboxitem()
        myInbox = inboxdata[indexPath.row]
     //   inboxcell.heightForLocations.constant = getHeightForText(text: myInbox.location)
        inboxcell.producttitle.text = myInbox.location
        inboxcell.username.text = myInbox.itemusername
        inboxcell.dateLabel.text = myInbox.fromDate;
        inboxcell.statusLabel.text = myInbox.status
        
        let itemimg = myInbox.itemuserimage
        inboxcell.selectionStyle = .none
            
        inboxcell.profilePicImageview.sd_setImage(with: URL(string: itemimg!), placeholderImage: UIImage(named: "upload"))
        return inboxcell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.performSegue(withIdentifier: "GotoAccept", sender: self)
    }

    func getinboxdata()
    {
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
        ref = FIRDatabase.database().reference()
        ref.child("User_Profiles").child(userID).child("Inbox").observe(.value, with:  { (snapshot) in
            
            var inbox = [Inboxitem]()
            for id in snapshot.children
            {
                let newshare = Inboxitem(snapshot: id as! FIRDataSnapshot)
                inbox.insert(newshare, at: 0)
                print(inbox)
            }
            self.inboxdata = inbox
            DispatchQueue.main.async(execute: {
                self.Inboxtable.reloadData()
            })
        })
        { (error) in
            print(error.localizedDescription)
        }
    }
   
    @IBAction func backbuttontapped(_ sender: UIBarButtonItem!)
    {
        if revealViewController() != nil
        {
            // revealViewController().rearViewRevealWidth = 62
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rightViewRevealWidth = 150
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        //self.navigationController?.popViewController(animated: true)
        //_ = navigationController?.popToRootViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "GotoAccept"
        {
            let acceptvc: MessageViewController = segue.destination as! MessageViewController
            let indexpaths: IndexPath = self.Inboxtable.indexPathForSelectedRow!
            let indexpath = indexpaths.row
            let model = inboxdata[indexpath]
            acceptvc.PathString = model.path!
        }
    }
    
}
