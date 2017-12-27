//
//  ShareDetailsViewController.swift
//  
//
//  Created by Dawn on 17/05/17.
//
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth


class ShareDetailsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var lblComments: UILabel!
    
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet var postimg: UIImageView!
    @IBOutlet var posttitle: UILabel!
    @IBOutlet var username: UILabel!
    @IBOutlet var userimage: UIImageView!
    @IBOutlet var userdetails: UILabel!
    @IBOutlet var postdate: UILabel!
    @IBOutlet var producttitle: UILabel!
    @IBOutlet var productdes: UILabel!
    @IBOutlet var detailview: UIScrollView!
    @IBOutlet var commentview: UIView!
    @IBOutlet var sendcommentview: UIView!
    @IBOutlet var commentTable: UITableView!
    @IBOutlet var commentField: UITextField!
    @IBOutlet var CommentsBtn: UIButton!
    @IBOutlet var DetailBtn: UIButton!
    @IBOutlet var changeLbl: UILabel!
    
    var productData: shareitem!
    var Sharepath = String()
    var ref: FIRDatabaseReference!
    var storageREF : FIRStorageReference!
    var commentdata = [commentitem]()
    var commenteduser = String()
    var productDataURL: String  = ""

    override func viewWillAppear(_ animated: Bool)
    {
       // self.getcommentdata()
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        //self.getsharedetailsfromdb()
        self.detailview.isHidden = true
        self.commentview.isHidden = false
        self.sendcommentview.isHidden = false
        self.configureUI()
        self.getcommentdata()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func configureUI()
    {
        print(productData.itemimage!)
        postimg.sd_setImage(with: URL(string: productData.itemimage!), placeholderImage: UIImage(named: "login-bg"))
        lblLikes.text = productData.likesForPost!+"Likes"
        lblComments.text = productData.commentsCount! + "Comments"
        lblPoints.text = String(format: "Points (%d)",productData.userPoints)
        lblLikes.text = productData.likesCount!+"Likes"
        posttitle.text = productData.itemtitle!
        username.text = productData.itemusername!
        var badgeRank: String = ""
        badgeRank = badgeRank+productData.userBadge!+"Badges,Rank"+productData.userRank!
        userdetails.text = badgeRank
        producttitle.text = productData.itemtitle!
        productdes.text = productData.itemdes
       userimage.sd_setImage(with: URL(string: productData.itemuserimage!), placeholderImage: UIImage(named: "login-bg"))
    }
    @IBAction func segmentbuttonaction(_ sender: UIButton) {
        let selected = sender.tag
        switch selected
        {
        case 100:
            self.detailview.isHidden = true
            self.commentview.isHidden = false
            self.sendcommentview.isHidden = false
            self.getcommentdata()
            UIView.animate(withDuration: 0.5, animations: {
                 self.changeLbl.frame = CGRect(x: self.CommentsBtn.frame.origin.x, y: self.changeLbl.frame.origin.y, width: self.CommentsBtn.frame.size.width, height: self.changeLbl.frame.size.height )
                self.CommentsBtn.backgroundColor = UIColor.init(colorLiteralRed: 5.0/255.0, green: 46.0/255.0, blue: 89.0/255.0, alpha: 1)
                self.DetailBtn.backgroundColor = UIColor.init(colorLiteralRed: 9.0/255.0, green: 71.0/255.0, blue: 138.0/255.0, alpha: 1)
                
            })

            break
        case 200:
           self.detailview.isHidden = false
           self.commentview.isHidden = true
           self.sendcommentview.isHidden = true
          // getsharedetailsfromdb()
           UIView.animate(withDuration: 0.5, animations: {
            self.changeLbl.frame = CGRect(x: self.DetailBtn.frame.origin.x, y: self.changeLbl.frame.origin.y, width: self.DetailBtn.frame.size.width, height: self.changeLbl.frame.size.height )
            self.DetailBtn.backgroundColor = UIColor.init(colorLiteralRed: 5.0/255.0, green: 46.0/255.0, blue: 89.0/255.0, alpha: 1)
            self.CommentsBtn.backgroundColor = UIColor.init(colorLiteralRed: 9.0/255.0, green: 71.0/255.0, blue: 138.0/255.0, alpha: 1)
            
           })

            break
            
        default:
            self.getcommentdata()
            self.detailview.isHidden = true
            self.commentview.isHidden = false
            self.sendcommentview.isHidden = false
            
            UIView.animate(withDuration: 0.5, animations: {
                self.changeLbl.frame = CGRect(x: self.CommentsBtn.frame.origin.x, y: self.changeLbl.frame.origin.y, width: self.CommentsBtn.frame.size.width, height: self.changeLbl.frame.size.height )
                self.CommentsBtn.backgroundColor = UIColor.init(colorLiteralRed: 5.0/255.0, green: 46.0/255.0, blue: 89.0/255.0, alpha: 1)
                self.DetailBtn.backgroundColor = UIColor.init(colorLiteralRed: 9.0/255.0, green: 71.0/255.0, blue: 138.0/255.0, alpha: 1)
            })
            break
        }
    }
    
    @IBAction func actionLikeButtonPressed(_ sender: Any)
    {
//        let  btn = sender
//        selectedindex = btn.tag
        
        var mytimeline = shareitem()
        mytimeline = productData
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
                        self.productData.likesCount = "\(likesCount)"
                        self.configureUI();
//                        self.gettimelinedata()
//                        self.getNearByData()
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
//                        print("completed")
//                        self.getMyFavouriteData()
//                        self.gettimelinedata()
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
                self.productData.likesCount = "\(likesCount)"
                self.configureUI()
            }
            else
            {
                
            }
        })
    }
    
    // Tableview Datasource Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return commentdata.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let commentcell: CommentsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "commentcell") as! CommentsTableViewCell
        ref = FIRDatabase.database().reference()
        var comments = commentitem()
        comments = commentdata[indexPath.row]
        commentcell.commentText.text = comments.commenttext
        commentcell.sendTime.text = comments.date
        self.commenteduser = comments.itemusername!
        commentcell.btnReply.isHidden = true
        
        ref.child("User_Profiles").child(comments.itemusername!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value)
            let value = snapshot.value as? NSDictionary
            commentcell.username.text = value?["userName"] as? String
            if snapshot.hasChild("userProfilePic"){
                
                if snapshot.hasChild("userProfilePic"){
                    let filepath = value?["userProfilePic"]
                    commentcell.userImage.sd_setImage(with: URL(string: filepath as! String), placeholderImage: UIImage(named: "upload"))
                } else{
                    commentcell.userImage.image = UIImage(named: "upload")
                }
            }
            else
            {
                commentcell.userImage.image = UIImage(named: "upload")
            }
        })
        return commentcell
    }
    

    func getsharedetailsfromdb()
    {
        var postuserid = String()
        ref = FIRDatabase.database().reference()
        storageREF = FIRStorage.storage().reference()
        ref.child("Share").child("sharesall").child("Electronics").child(Sharepath).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value)
            let value = snapshot.value as? NSDictionary
            self.posttitle.text = value?["title"] as? String
            self.producttitle.text = value?["title"] as? String
            self.productdes.text = value?["strDescription"] as! String?
            self.postdate.text = value?["date"] as! String?
            if (value?["uid"]) != nil
            {
                postuserid = (value?["uid"] as! String?)!
                self.displayUserdata(userid: postuserid)
            }
            if snapshot.hasChild("imgUrl"){
                let filepath = value?["imgUrl"]
                if filepath != nil {
                    self.productDataURL = filepath as! String;
                    FIRStorage.storage().reference(forURL: filepath as! String).data(withMaxSize: 10*1024*1024, completion: { (data, error) in
                        
                        if   let userPhoto = UIImage(data: (data)!){
                            self.postimg.image = userPhoto
                        }else {
                            self.postimg.image = UIImage(named: "upload")
                        }
                        
                    })
                   
                }else{
                    self.postimg.image = UIImage(named: "upload")
                }}
        })
        {  (error) in
            print(error.localizedDescription)
        }

    }
    
    func displayUserdata(userid: String){
        let userID = userid
        ref = FIRDatabase.database().reference()
        storageREF = FIRStorage.storage().reference()
        ref.child("User_Profiles").child("\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value)
            let value = snapshot.value as? NSDictionary
            self.username.text = value?["userName"] as? String
            if snapshot.hasChild("userProfilePic"){
                let filepath = value?["userProfilePic"]

                if snapshot.hasChild("userProfilePic"){
                    let filepath = value?["userProfilePic"]
                    self.userimage.sd_setImage(with: URL(string: filepath as! String), placeholderImage: UIImage(named: "upload"))
                } else{
                    self.userimage.image = UIImage(named: "upload")
                }
            }
        })
        {  (error) in
            print(error.localizedDescription)
        }
    }
    
    @IBAction func requestformaction(_ sender: Any)
    {
        self.performSegue(withIdentifier: "GotoRequestform", sender: self)
    }
   
    @IBAction func senCommentAction(_ sender: Any)
    {
        let commentStr : String = self.commentField.text!
        let trimmedString = commentStr.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedString.characters.count > 0
        {
            var ref = FIRDatabase.database().reference()
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
        
            ref.child("Share").child("sharesall").child(productData.key).child("comments").childByAutoId().setValue(commentinfo)
            self.commentField.text = ""
            //"commentsCount"
            var commentCount:Int = (self.productData.value(forKey:"commentsCount") as! NSString).integerValue
            commentCount = commentCount+1
            
            let ref1 = FIRDatabase.database().reference().child("Share").child("sharesall").child(self.productData.path!)
            ref1.updateChildValues([
                "commentsCount": commentCount
                ])
        }
        else
        {
            self.showAlertView(withTitle:"Please nter text")
        }
    }
    
    func getcommentdata()
    {
        print(productData.key)
        ref = FIRDatabase.database().reference()
        ref.child("Share").child("sharesall").child(productData.key).child("comments").observe(.value, with:  { (snapshot) in
            
            var share = [commentitem]()
            
            for id in snapshot.children {
                
                let newshare = commentitem(snapshot: id as! FIRDataSnapshot)
                
                share.insert(newshare, at: 0)
                print(share)
            }
            self.commentdata = share
            let count = self.commentdata.count
            self.lblComments.text = "\(count)Comments"
            DispatchQueue.main.async(execute: {
                self.commentTable.reloadData()
            })
            
            /*  { (error) in
             print(error.localizedDescription)*/
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "GotoRequestform"{
            
            let requestvc: requestFormViewController = (segue.destination as? requestFormViewController)!
            
            requestvc.productData = productData
        }
    }
    

}
