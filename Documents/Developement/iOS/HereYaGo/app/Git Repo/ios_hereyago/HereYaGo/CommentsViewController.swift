//
//  CommentsViewController.swift
//  HereYaGo
//
//  Created by Dawn on 29/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet var commentField: UITextField!
    @IBOutlet var CommentsTable: UITableView!
    var pathid: String?
    var ref : FIRDatabaseReference!
    var commentdata = [commentitem]()
    var commenteduser = String()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
       ref = FIRDatabase.database().reference()
        self.getcommentdata()
        print(pathid)

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionBackButton(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Tableview Datasource Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentdata.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let commentcell: CommentsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "commentcell") as! CommentsTableViewCell
        ref = FIRDatabase.database().reference()
        var comments = commentitem()
        comments = commentdata[indexPath.row]
        commentcell.commentText.text = comments.commenttext
        commentcell.sendTime.text = comments.date
        self.commenteduser = comments.itemusername!
        
        ref.child("User_Profiles").child(comments.itemusername!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value)
            let value = snapshot.value as? NSDictionary
            commentcell.username.text = value?["userName"] as? String
            if snapshot.hasChild("userProfilePic"){
                let filepath = value?["userProfilePic"]
                if filepath != nil {
                    FIRStorage.storage().reference(forURL: filepath as! String).data(withMaxSize: 10*1024*1024, completion: { (data, error) in
                        let imagedata = data
                        if imagedata != nil{
                            //   if   let userPhoto = UIImage(data: (data)!){
                            commentcell.userImage.image = UIImage(data: imagedata!)
                        }else {
                            commentcell.userImage.image = UIImage(named: "upload")
                        }
                    })
                      
                }
            }
        })
        
        return commentcell
    }
    
    

    @IBAction func Commentsendaction(_ sender: Any) {
        ref = FIRDatabase.database().reference()
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .medium
        dateFormatter1.dateFormat = "dd-MM-yyyy"
        let date = dateFormatter1.string(from: NSDate() as Date)
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .medium
        timeFormatter.dateFormat = "hh:mm:ss a"
        let time = timeFormatter.string(from: Date() as Date)
        let userID =  UserDefaults.standard.value(forKey:Constant.UserDefaultUserId)! as! String
        let commentinfo : Dictionary<String, Any> = ["comment": self.commentField.text!,
                                                     "uid": userID,
                                                     "date": "\(date) \(time)"]
        ref.child("Share").child("sharesall").child("Electronics").child(pathid!).child("comments").childByAutoId().setValue(commentinfo)
        self.commentField.text = ""
    }
    func getcommentdata(){
        ref = FIRDatabase.database().reference()
        ref.child("Share").child("sharesall").child("Electronics").child(pathid!).child("comments").observe(.value, with:  { (snapshot) in
            
            var share = [commentitem]()
            
            for id in snapshot.children {
                
                let newshare = commentitem(snapshot: id as! FIRDataSnapshot)
                
                share.insert(newshare, at: 0)
                print(share)
            }
            self.commentdata = share
            DispatchQueue.main.async(execute: {
                self.CommentsTable.reloadData()
            })
            
            /*  { (error) in
             print(error.localizedDescription)*/
        })
        
    }

}
