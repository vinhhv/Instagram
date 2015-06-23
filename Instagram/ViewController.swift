//
//  ViewController.swift
//  Instagram
//
//  Created by Vinh Vu on 6/21/15.
//  Copyright (c) 2015 Vinguh Industries. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var formButton: UIButton!
    @IBOutlet var registerButtonText: UIButton!
    @IBOutlet var registeredText: UILabel!
    
    var signupActive:Bool = true
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    func displayAlert(title: String, message: String)
    {
        var alert:UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func formButtonPressed(sender: AnyObject) {
        if username.text == "" || password.text == ""
        {
            displayAlert("Empty Field", message: "Please enter a username and password")
        }
        else
        {
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            if signupActive == true
            {
                var user:PFUser = PFUser()
                user.username = username.text
                user.password = password.text
                
                var errorMessage:String = "Please try again later!"
                
                user.signUpInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if error == nil
                    {
                        // Signup successful
                        self.performSegueWithIdentifier("login", sender: self)
                    }
                    else
                    {
                        
                        if let errorString = error!.userInfo?["error"] as? String
                        {
                            errorMessage = errorString
                        }
                        
                        self.displayAlert("Failed to Signup", message: errorMessage)
                    }
                })
            }
            else
            {
                PFUser.logInWithUsernameInBackground(username.text, password: password.text, block: { (user:PFUser?, error:NSError?) -> Void in
                    
                    var errorMessage:String = "Please try again later!"
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    if user != nil
                    {
                        // Logged In!
                        self.performSegueWithIdentifier("login", sender: self)
                    }
                    else
                    {
                        if let errorString = error!.userInfo?["error"] as? String
                        {
                            errorMessage = errorString
                        }
                        self.displayAlert("Failed to Log In", message:  errorMessage)
                    }
                })
            }
        }
    }
    
    
    @IBAction func registerButtonPressed(sender: AnyObject) {
        
        if signupActive == true
        {
            formButton.setTitle("Log In", forState: UIControlState.Normal)
        
            registeredText.text = "Not Registered?"
            registerButtonText.setTitle("Sign Up", forState: UIControlState.Normal)
            signupActive = false
        }
        else
        {
            formButton.setTitle("Sign Up", forState: UIControlState.Normal)
            
            registeredText.text = "Already Registered?"
            registerButtonText.setTitle("Log In", forState: UIControlState.Normal)
            signupActive = true
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil
        {
            self.performSegueWithIdentifier("login", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

