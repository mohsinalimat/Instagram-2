//
//  newsVC.swift
//  Instagram
//
//  Created by Bobby Negoat on 12/12/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Parse

class newsVC: UITableViewController {

    // arrays to hold data from server
   fileprivate var usernameArray = [String]()
   fileprivate var avaArray = [PFFile]()
   fileprivate var typeArray = [String]()
   fileprivate var dateArray = [Date?]()
   fileprivate var uuidArray = [String]()
   fileprivate var ownerArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

      //set cell estimated height
        setTableViewCellAttributes()
        
        //set navigation bar attributes
        setNaviAttributes()
        
        // request notifications
       requestNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func usernameBtn_click(_ sender: Any) {
        
// call index of button
let i = (sender as AnyObject).layer.value(forKey: "index") as! IndexPath
        
// call cell to call further cell data
let cell = tableView.cellForRow(at: i) as! newsCell
        
// if user tapped on himself go home, else go guest
if cell.usernameBtn.titleLabel?.text == PFUser.current()?.username {
let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
self.navigationController?.show(home, sender: nil)
} else {

guestName.append(cell.usernameBtn.titleLabel!.text!)
let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
self.navigationController?.show(guest, sender: nil)
        }
    }
}// newsVC class over line

//custom functions
extension newsVC{
    
    fileprivate func  setTableViewCellAttributes(){
        // dynamic tableView height - dynamic cell
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
    }
    
    fileprivate func setNaviAttributes(){
        
        // title at the top
        self.navigationItem.title = "NOTIFICATIONS"
    }
   
    fileprivate func requestNotifications(){
        
let query = PFQuery(className: "news")
query.whereKey("to", equalTo: PFUser.current()!.username!)
query.limit = 30
query.findObjectsInBackground (block: { (objects, error) in
    if error == nil {
                
    // clean up
self.usernameArray.removeAll(keepingCapacity: false)
self.avaArray.removeAll(keepingCapacity: false)
self.typeArray.removeAll(keepingCapacity: false)
self.dateArray.removeAll(keepingCapacity: false)
self.uuidArray.removeAll(keepingCapacity: false)
self.ownerArray.removeAll(keepingCapacity: false)
                
 // found related objects
        for object in objects! {

self.usernameArray.append(object.object(forKey: "by") as! String)
self.avaArray.append(object.object(forKey: "ava") as! PFFile)
self.typeArray.append(object.object(forKey: "type") as! String)
self.dateArray.append(object.createdAt)
self.uuidArray.append(object.object(forKey: "uuid") as! String)
self.ownerArray.append(object.object(forKey: "owner") as! String)
            
        // save notifications as checked
        object["checked"] = "yes"
        object.saveEventually()
}
                
// reload tableView to show received data
self.tableView.reloadData()
            }
        })
    }
}

//UITableViewDatasource
extension newsVC{
    
    // cell numb
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    // cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // declare cell
let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! newsCell
        
// connect cell objects with received data from server
cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: UIControlState())
avaArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                cell.avaImg.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        // calculate post date
        let from = dateArray[indexPath.row]
        let now = Date()
        let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = (Calendar.current as NSCalendar).components(components, from: from!, to: now, options: [])
        
        // logic what to show: seconds, minuts, hours, days or weeks
        if difference.second! <= 0 {
            cell.dateLbl.text = "now"
        }
        if difference.second! > 0 && difference.minute! == 0 {
            cell.dateLbl.text = "\(difference.second!)s."
        }
        if difference.minute! > 0 && difference.hour! == 0 {
            cell.dateLbl.text = "\(difference.minute!)m."
        }
        if difference.hour! > 0 && difference.day! == 0 {
            cell.dateLbl.text = "\(difference.hour!)h."
        }
        if difference.day! > 0 && difference.weekOfMonth! == 0 {
            cell.dateLbl.text = "\(difference.day!)d."
        }
        if difference.weekOfMonth! > 0 {
            cell.dateLbl.text = "\(difference.weekOfMonth!)w."
        }
        
    // define info text
    if typeArray[indexPath.row] == "mention" {
            cell.infoLbl.text = "has mentioned you."
        }
if typeArray[indexPath.row] == "comment" {
        cell.infoLbl.text = "has commented your post."
    }
if typeArray[indexPath.row] == "follow" {
            cell.infoLbl.text = "now following you."
}
if typeArray[indexPath.row] == "like" {
    cell.infoLbl.text = "likes your post."
}
        
  // asign index of button
cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        
        return cell
    }
}

//UITableViewDelegate
extension newsVC{
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // call cell for calling cell data
        let cell = tableView.cellForRow(at: indexPath) as! newsCell
        
        // going to @menionted comments
        if cell.infoLbl.text == "has mentioned you." {
            
            // send related data to gloval variable
            commentuuid.append(uuidArray[indexPath.row])
            commentowner.append(ownerArray[indexPath.row])
            
            // go comments
            let comment = self.storyboard?.instantiateViewController(withIdentifier: "commentsNav") as! commentsNav
    self.navigationController?.show(comment, sender: nil)
        }
                
    // going to own comments
if cell.infoLbl.text == "has commented your post." {
            
// send related data to gloval variable
commentuuid.append(uuidArray[indexPath.row])
commentowner.append(ownerArray[indexPath.row])
            
// go comments
let comment = self.storyboard?.instantiateViewController(withIdentifier: "commentsNav") as! commentsNav
            
self.navigationController?.show(comment, sender: nil)

}
        
// going to user followed current user
if cell.infoLbl.text == "now following you." {
            
// take guestname
guestName.append(cell.usernameBtn.titleLabel!.text!)
            
    // go guest
let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
self.navigationController?.show(guest, sender: nil)
    }
        
        // going to liked post
        if cell.infoLbl.text == "likes your post." {
            
      // take post uuid
    postuuid.append(uuidArray[indexPath.row])
            
    // go post
let post = self.storyboard?.instantiateViewController(withIdentifier: "postVC") as! postVC
self.navigationController?.show(post, sender: nil)
        }
}
}
