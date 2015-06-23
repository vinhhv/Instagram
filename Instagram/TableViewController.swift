//
//  TableViewController.swift
//  Instagram
//
//  Created by Vinh Vu on 6/22/15.
//  Copyright (c) 2015 Vinguh Industries. All rights reserved.
//

import UIKit
import Parse

class TableViewController: UITableViewController {
    
    var usernames:[String] = [String]()
    var userids:[String] = [String]()
    var isFollowing = [String:Bool]()
    
    var refresher:UIRefreshControl!
    var activityIndicator = UIActivityIndicatorView()
    
    func displayAlert(title: String, message: String)
    {
        var alert:UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    func refresh()
    {
        var query = PFUser.query()
        query?.findObjectsInBackgroundWithBlock({ (objects, error:NSError?) -> Void in
            
            if let users = objects
            {
                self.usernames.removeAll(keepCapacity: true)
                self.userids.removeAll(keepCapacity: true)
                self.isFollowing.removeAll(keepCapacity: true)
                
                for object in users
                {
                    if let user = object as? PFUser
                    {
                        if user.objectId! != PFUser.currentUser()?.objectId
                        {
                            self.usernames.append(user.username!)
                            self.userids.append(user.objectId!)
                            
                            var query = PFQuery(className: "followers")
                            query.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
                            query.whereKey("following", equalTo: user.objectId!)
                            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                                if let objects = objects
                                {
                                    if objects.count > 0
                                    {
                                        self.isFollowing[user.objectId!] = true
                                    }
                                    else
                                    {
                                        self.isFollowing[user.objectId!] = false
                                    }
                                }
                                if self.isFollowing.count == self.usernames.count
                                {
                                    self.tableView.reloadData()
                                    self.refresher.endRefreshing()
                                }
                            })
                        }
                    }
                }
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "signOut"
        {
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            self.activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
            self.activityIndicator.center = self.view.center
            self.activityIndicator.hidesWhenStopped = true
            self.activityIndicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
            self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            self.view.addSubview(self.activityIndicator)
            PFUser.logOutInBackgroundWithBlock({ (error) -> Void in
                
                if error == nil
                {
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    self.displayAlert("Sign Out Successful", message: "You have been signed out!")
                }
                else
                {
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    self.displayAlert("Sign Out Error", message: "Unable to sign out, please try again!")
                }
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull down to refresh")
        
        // ValueChanged - someone has pulled down to refresh
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        
        refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel?.text = usernames[indexPath.row]
        
        let followedObjectId = userids[indexPath.row]
        
        if isFollowing[followedObjectId] == true
        {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        let followedObjectId = userids[indexPath.row]
        
        if isFollowing[followedObjectId] == false
        {
            isFollowing[followedObjectId] = true
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            var following = PFObject(className: "followers")
            following["following"] = userids[indexPath.row]
            following["follower"] = PFUser.currentUser()?.objectId
            
            following.saveInBackground()
        }
        else
        {
            isFollowing[followedObjectId] = false
            cell.accessoryType = UITableViewCellAccessoryType.None
            
            var query = PFQuery(className: "followers")
            query.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
            query.whereKey("following", equalTo: userids[indexPath.row])
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if let objects = objects
                {
                    for object in objects
                    {
                        object.deleteInBackground()
                    }
                }
            })

            
        }
    }


}
