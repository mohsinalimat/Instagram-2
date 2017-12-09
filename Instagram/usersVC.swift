//
//  usersVC.swift
//  Instagram
//
//  Created by Bobby Negoat on 12/9/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Parse

class usersVC: UITableViewController,UISearchBarDelegate {

    // declare search bar
var searchBar = UISearchBar()
    
    // tableView arrays to hold information from server
    var usernameArray = [String]()
var avaArray = [PFFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

       //
        setSearchBarAttributes()
       
        //
        loadUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}//usersVC class over line

extension usersVC{
    
    fileprivate func setSearchBarAttributes(){
        
        // implement search bar
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor.groupTableViewBackground
        searchBar.frame.size.width = self.view.frame.size.width - 34
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = searchItem
    }
    
    // load users function
   fileprivate func loadUsers() {
        
        let usersQuery = PFQuery(className: "_User")
        usersQuery.addDescendingOrder("createdAt")
        usersQuery.limit = 20
        usersQuery.findObjectsInBackground (block: { (objects, error) in
            if error == nil {
                
                // clean up
self.usernameArray.removeAll(keepingCapacity: false)
self.avaArray.removeAll(keepingCapacity: false)
                
    // found related objects
   for object in objects! {
    
self.usernameArray.append(object.value(forKey: "username") as! String)
self.avaArray.append(object.value(forKey: "ava") as! PFFile)
}
                
        // reload
           self.tableView.reloadData()
} else {print(error!.localizedDescription)}
        })
    }
}

//UISearchBarDelegate
extension usersVC{
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
// find by username
let usernameQuery = PFQuery(className: "_User")
usernameQuery.whereKey("username", matchesRegex: "(?i)" + searchBar.text!)
usernameQuery.findObjectsInBackground (block: { (objects, error) in
            if error == nil {
                
       // if no objects are found according to entered text in usernaem colomn, find by fullname
    if objects!.isEmpty {
                    
let fullnameQuery = PFUser.query()
fullnameQuery?.whereKey("fullname", matchesRegex: "(?i)" + self.searchBar.text!)
fullnameQuery?.findObjectsInBackground(block: { (objects, error) in
        if error == nil {
                            
            // clean up
self.usernameArray.removeAll(keepingCapacity: false)
self.avaArray.removeAll(keepingCapacity: false)
                            
    // found related objects
    for object in objects! {
self.usernameArray.append(object.object(forKey: "username") as! String)
self.avaArray.append(object.object(forKey: "ava") as! PFFile)
    }
                            
     // reload
        self.tableView.reloadData()
        }
    })
}

// clean up
self.usernameArray.removeAll(keepingCapacity: false)
self.avaArray.removeAll(keepingCapacity: false)
                
                // found related objects
        for object in objects! {
    self.usernameArray.append(object.object(forKey: "username") as! String)
    self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                }
                
                // reload
                self.tableView.reloadData()
            }
        })
        
        return true
    }
    
    // clicked cancel button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        // dismiss keyboard
        searchBar.resignFirstResponder()
        
        // hide cancel button
        searchBar.showsCancelButton = false
        
        // reset text
        searchBar.text = ""
        
        // reset shown users
        loadUsers()
    }
    
    // tapped on the searchBar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        // show cancel button
        searchBar.showsCancelButton = true
    }
}
