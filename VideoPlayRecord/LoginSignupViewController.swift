//
//  LoginSignupViewController.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 2/22/17.
//  Copyright © 2017 Will Bert. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class LoginSignupViewController: UIViewController {
    
    @IBOutlet weak var emailTextEntry: UITextField!
    @IBOutlet weak var passwordTextEntry: UITextField!
    
    @IBOutlet weak var googleSigninButton: UIButton!
    @IBOutlet weak var twitterSigninButton: UIButton!
    
    @IBOutlet weak var signupButton: UIButton!
    
    let usersOnlineRef = FIRDatabase.database().reference(withPath: "online-users")
    let usersRef = FIRDatabase.database().reference(withPath: "user-emails")
    
    var isLoginMode: Bool!
    
    override func viewWillAppear(_ animated: Bool) {
        //navigationController?.setNavigationBarHidden(true, animated: false);
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //add this line whnever a view has text input
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view, typically from a nib.
        self.signupButton.layer.cornerRadius = 4
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func signupPressed(_ sender: Any) {
        
        guard let password = passwordTextEntry.text else {
            return
        }
        guard let email = emailTextEntry.text else {
            return
        }
        
        if !isValid(password: password) {
            //show alert
            let alert = UIAlertController(title: "Password Invalid", message: "Password must be between 4 and 16 characters: \(emailTextEntry.text)", preferredStyle: .alert);
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                self.passwordTextEntry.text = "";
            });
            alert.addAction(okAction);
            present(alert, animated: true, completion: nil);
        }
        else if !isValid(email: email){
            let alert = UIAlertController(title: "Email Invalid", message: "Password must be between 4 and 16 characters", preferredStyle: .alert);
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                self.emailTextEntry.text = "";
            });
            alert.addAction(okAction);
            present(alert, animated: true, completion: nil);
        }
        else {
            //check for existing user
            let emailConverted = email.replacingOccurrences(of: ".", with: "dot");
            usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(emailConverted){
                    self.loginUser(email: email, password: password)
                }
                else {
                    self.createNewUser(email: email, password: password);
                }
            })
            
        }
        
    }
    
    func createNewUser (email : String, password : String) {
        FIRAuth.auth()!.createUser(withEmail: email,password: password) { user, error in
            if error == nil {
                let date = NSDate()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
                let nowDate = dateFormatter.string(from:date as Date)
                //add user ref to firebase for that email
                let emailConverted = email.replacingOccurrences(of: ".", with: "dot");
                self.usersRef.child(emailConverted).setValue(nowDate);
                
                FIRAuth.auth()!.signIn(withEmail: email,password: password){ (user, error) in
                    let currentUserRef = self.usersOnlineRef.child((user?.uid)!);
                    currentUserRef.setValue(user?.email!)
                    currentUserRef.onDisconnectRemoveValue()
                    //segue to tab bar stuff 
                    //self.performSegue(withIdentifier: "FromLoggedInToTabViewControllerSegue", sender: self);
                    //_ = self.navigationController?.popViewController(animated: true);
                    //Show a one-time: About Me view and a connect service view
                    NEW_USER = true
                    self.dismiss(animated: true, completion: nil);
                }
            }
        }
        
    }
    
    func loginUser(email: String, password: String){
        FIRAuth.auth()!.signIn(withEmail: email, password: password) { (user, error) in
            //enable watch and record buttons
            
            if user != nil {
                let currentUserRef = self.usersOnlineRef.child((user?.uid)!);
                currentUserRef.setValue(user?.email!)
                currentUserRef.onDisconnectRemoveValue()
                //go back to start view
                //_ = self.navigationController?.popViewController(animated: true);
                //segue to tab bar stuff
                //self.performSegue(withIdentifier: "FromLoggedInToTabViewControllerSegue", sender: self);
                //dismiss self
                self.dismiss(animated: true, completion: nil);
            }
        }
    }
    
    
    //TODO: add password strength
    func isValid(password: String) -> Bool {
        // check the password is between 4 and 16 characters
        if !(4...16 ~= password.characters.count) {
            return false
        }
        return true
    }
    
    //check that an actual email was entered
    func isValid(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    
}
