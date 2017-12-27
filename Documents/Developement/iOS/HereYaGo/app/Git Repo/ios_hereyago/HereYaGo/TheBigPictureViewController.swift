//
//  TheBigPictureViewController.swift
//  HereYaGo
//
//  Created by DawnShine on 16/05/17.
//  Copyright © Protected Technology  Pune.. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class TheBigPictureViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet var GlobalBtn: UIButton!
    @IBOutlet var LocalBtn: UIButton!
    @IBOutlet var BigPictureTable: UITableView!
    @IBOutlet var changeLbl: UILabel!
    var Bigpicture = [BigPictureitem]()
    var ref = FIRDatabaseReference()
    var storageref = FIRStorageReference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if revealViewController() != nil {
            //            revealViewController().rearViewRevealWidth = 62
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            revealViewController().rightViewRevealWidth = 150
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.getBpdataglobalfromBD()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.Bigpicture.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bigPicCell : BigPictureCell = BigPictureTable.dequeueReusableCell(withIdentifier: "bigpicturecell", for: indexPath) as! BigPictureCell
        var myBP = BigPictureitem()
        myBP = Bigpicture[indexPath.row]
        bigPicCell.lblMemberName.text = myBP.BPtitle
        bigPicCell.lblMemberDetails.text = myBP.date
        bigPicCell.lblProductdescription.text = myBP.imagedescription
        bigPicCell.lblProductName.text = myBP.Bpdescription
        bigPicCell.btnStar.tag = indexPath.row
        if let itemimg = myBP.imageurl{
            
            bigPicCell.imgProduct.sd_setImage(with: URL(string: itemimg as! String), placeholderImage: UIImage(named: "upload"))
            
//            storageref = FIRStorage.storage().reference(forURL: itemimg)
//            self.storageref.data(withMaxSize: 10*1024*1024, completion: { (data, error) in
//                
//                let userPhoto = UIImage(data: (data)!)
//                bigPicCell.imgProduct.setImage(userPhoto, for: .normal)
//            })
        } else{
            bigPicCell.imgProduct.image = UIImage(named: "login-bg")
        }
     /*   self.ref.child("User_Profiles").child(myBP.userid!).observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? NSDictionary
        //    bigPicCell.lblMemberName.text = value?["userName"] as! String?
            let filepath = value?["userPhoto"]
            if filepath != nil{
                FIRStorage.storage().reference(forURL: filepath as! String).data(withMaxSize: 10*1024*1024, completion: { (data, error) in
                    
                    if   let userPhoto = UIImage(data: (data)!){
                        timelineCell.imgMember.image = userPhoto
                    }else {
                        timelineCell.imgMember.image = UIImage(named: "upload")
                    }
                    
                })
            }else {
                timelineCell.imgMember.image = UIImage(named: "upload")}
            
        }) { (error) in
            print(error.localizedDescription)
        } */

        
        
        
        return bigPicCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 260.0
    }
    
    @IBAction func buttontaped(_ sender: UIButton) {
        
        let buttontitle = sender.tag
        switch  buttontitle {
        case 100:
            self.getBpdataglobalfromBD()
            UIView.animate(withDuration: 0.5, animations: {
                 self.changeLbl.frame = CGRect(x: self.GlobalBtn.frame.origin.x, y: self.changeLbl.frame.origin.y, width: self.GlobalBtn.frame.size.width, height: self.changeLbl.frame.size.height )
                self.GlobalBtn.backgroundColor = UIColor.init(colorLiteralRed: 5.0/255.0, green: 46.0/255.0, blue: 89.0/255.0, alpha: 1)
                self.LocalBtn.backgroundColor = UIColor.init(colorLiteralRed: 9.0/255.0, green: 71.0/255.0, blue: 138.0/255.0, alpha: 1)
                
            })

            break
        case 200:
            self.getBpdatalocalfromBD()
            UIView.animate(withDuration: 0.5, animations: {
                self.changeLbl.frame = CGRect(x: self.LocalBtn.frame.origin.x, y: self.changeLbl.frame.origin.y, width: self.LocalBtn.frame.size.width, height: self.changeLbl.frame.size.height )
                self.LocalBtn.backgroundColor = UIColor.init(colorLiteralRed: 5.0/255.0, green: 46.0/255.0, blue: 89.0/255.0, alpha: 1)
                self.GlobalBtn.backgroundColor = UIColor.init(colorLiteralRed: 9.0/255.0, green: 71.0/255.0, blue: 138.0/255.0, alpha: 1)
                
            })
            break
        default:
            self.getBpdataglobalfromBD()
            UIView.animate(withDuration: 0.5, animations: {
                self.changeLbl.frame = CGRect(x: self.GlobalBtn.frame.origin.x, y: self.changeLbl.frame.origin.y, width: self.GlobalBtn.frame.size.width, height: self.changeLbl.frame.size.height )
                self.GlobalBtn.backgroundColor = UIColor.init(colorLiteralRed: 5.0/255.0, green: 46.0/255.0, blue: 89.0/255.0, alpha: 1)
                self.LocalBtn.backgroundColor = UIColor.init(colorLiteralRed: 9.0/255.0, green: 71.0/255.0, blue: 138.0/255.0, alpha: 1)
                
            })
            break
            
        }
        
    }
    
    func getBpdataglobalfromBD(){
        ref = FIRDatabase.database().reference()
        ref.child("BigPicture").queryOrdered(byChild: "localOrGlobal").queryEqual(toValue: "global").observeSingleEvent(of: .value, with:  { (snapshot) in
            
            var Bpitem = [BigPictureitem]()
            for id in snapshot.children {
                
                let newBp = BigPictureitem(snapshot: id as! FIRDataSnapshot)
                Bpitem.insert(newBp, at: 0)
                print(Bpitem)
                
            }
            self.Bigpicture = Bpitem
            DispatchQueue.main.async(execute: {
                self.BigPictureTable.reloadData()
                
            })
        })
            
        { (error) in
            print(error.localizedDescription)
        }

    }
    
    func getBpdatalocalfromBD()
    {
        ref = FIRDatabase.database().reference()
        ref.child("BigPicture").queryOrdered(byChild: "localOrGlobal").queryEqual(toValue: "local").observeSingleEvent(of: .value, with:  { (snapshot) in
            
            
            
            var Bpitem = [BigPictureitem]()
            
            for id in snapshot.children {
                
                
                let newBp = BigPictureitem(snapshot: id as! FIRDataSnapshot)
                
                Bpitem.insert(newBp, at: 0)
                print(Bpitem)
                
            }
            self.Bigpicture = Bpitem
            DispatchQueue.main.async(execute: {
                self.BigPictureTable.reloadData()
                
            })
        })
            
        { (error) in
            print(error.localizedDescription)
        }
        
    }

}
