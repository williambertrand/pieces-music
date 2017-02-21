//
//  ViewController.swift
//  VideoPlayRecord
//
//  Created by Andy (Test) on 1/31/15.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    
    @IBOutlet var logInButton: UIButton!
    @IBOutlet var signUpButton: UIButton!
    
    
    @IBOutlet var watchButton: UIButton!
    @IBOutlet var recordButton: UIButton!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        logInButton.isHidden = true
        signUpButton.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //see if user is authenticated or not
        if FIRAuth.auth()!.currentUser != nil {
            //user is logged in - don't show login and signup buttons
        }
        else {
            logInButton.isHidden = false
            signUpButton.isHidden = false
            
            watchButton.isHidden = true
            recordButton.isHidden = true
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    func createNewUser (email : String, password : String) {
        FIRAuth.auth()!.createUser(withEmail: email,password: password) { user, error in
            if error == nil {
                FIRAuth.auth()!.signIn(withEmail: email,password: password){ (user, error) in
                    //enable watch and record buttons
                }
            }
        }
    }
    
    func loginUser(email: String, password: String){
        FIRAuth.auth()!.signIn(withEmail: email, password: password) { (user, error) in
            //enable watch and record buttons
        }
    }

}

