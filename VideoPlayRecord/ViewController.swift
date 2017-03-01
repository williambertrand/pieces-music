//
//  ViewController.swift
//  VideoPlayRecord
//
//  Created by Andy (Test) on 1/31/15.
//  Copyright (c) 2015 Will Bert. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    
    @IBOutlet var logInButton: UIButton!
    @IBOutlet var signUpButton: UIButton!
    
    
    @IBOutlet var watchButton: UIButton!
    @IBOutlet var recordButton: UIButton!
    
    @IBOutlet weak var userIdLabel: UILabel!
    
    @IBOutlet weak var logOutButton: UIButton!
    
    //let usersRef = FIRDatabase.database().reference(withPath: "online")
    
    var spotifyLoggin = true //TODO
    var SPTUserLabel : UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        if FIRAuth.auth()!.currentUser != nil {
            DispatchQueue.main.async {
                self.signUpButton.isHidden = true;
                self.logInButton.isHidden = true;
                self.logOutButton.isHidden = false;
            }
        }
        else {
            self.logOutButton.isHidden = true;
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let width = self.view.frame.width;
        let height = self.view.frame.height;
        //see if user is authenticated or not TODO
        if FIRAuth.auth()!.currentUser != nil {
            Current_User = User(authData: FIRAuth.auth()!.currentUser!);
            //user is logged in - don't show login and signup buttons
            self.userIdLabel.text = Current_User.email;
            
        }
        else {
            logInButton.isHidden = false
            signUpButton.isHidden = false
            //watchButton.isHidden = true
            //recordButton.isHidden = true
            watchButton.isEnabled = false
            recordButton.isEnabled = false
            
            DispatchQueue.main.async {
                self.logOutButton.isHidden = true;
            }
            
            self.userIdLabel.text = "Not Logged in";
        }
        
        FIRAuth.auth()!.addStateDidChangeListener { auth, user in
            if user != nil {
                Current_User = User(authData: user!)
                self.userIdLabel.text = Current_User.email;
                
                DispatchQueue.main.async {
                    self.logOutButton.isHidden = false;
                }
            }
        }
        
        if spotifyLoggin == true {
            //self.addSpotifyView(width:width, height: height);
        }
        
        //DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            //self.SPTUserLabel.text = Spotify_Auth.session.canonicalUsername;
        //}
        
    }
    
    func addSpotifyView(width: CGFloat, height: CGFloat){
        let logoFrame = CGRect(x: width * 0.8, y: height * 0.9, width: width * 0.075, height: height * 0.075);
        let logoView = UIImageView(frame: logoFrame)
        logoView.image = UIImage(named: "spotify-1");
        logoView.contentMode = .scaleAspectFit;
        
        let labelFrame = CGRect(x: width * 0.875, y: height * 0.9, width: width * 0.2, height: height * 0.08);
        SPTUserLabel = UILabel(frame: labelFrame);
        SPTUserLabel.font = UIFont(name: "Helvetica", size: 8);
        SPTUserLabel.text = "Logged in";
        SPTUserLabel.textAlignment = .left;
        SPTUserLabel.contentMode = .left;
        
        self.view.addSubview(logoView);
        self.view.addSubview(SPTUserLabel);
        
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        try! FIRAuth.auth()!.signOut()
        
        DispatchQueue.main.async {
            self.recordButton.isHidden = true;
            self.watchButton.isHidden = true;
            self.logInButton.isHidden = false
            self.signUpButton.isHidden = false
            self.view.layoutSubviews()
        }
        Current_User = nil;
        self.userIdLabel.text = "Logged Out"
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginToPieces" {
            let vc = segue.destination as! LoginSignupViewController
            //vc.signupButton.setTitle("Log In", for: []);
            vc.isLoginMode = true;
        }
        else if segue.identifier == "SignupForPieces" {
            let vc = segue.destination as! LoginSignupViewController
            //vc.signupButton.setTitle("Sign Up", for: []);
            vc.isLoginMode = false;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

