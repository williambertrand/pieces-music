//
//  LoginSignupViewController.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 2/22/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
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
    
    var isLoginMode: Bool!
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false);
        
        if self.isLoginMode == true {
            self.signupButton.setTitle("Log In", for: []);
        }
        else {
            self.signupButton.setTitle("Sign Up", for: []);
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //add this line whnever a view has text input
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view, typically from a nib.
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
            let alert = UIAlertController(title: "Password Invalid", message: "Password must be between 4 and 16 characters", preferredStyle: .alert);
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
            
            if isLoginMode == nil {
                print("Issue with setting login mode");
            }
            
            if isLoginMode == true {
                loginUser(email: email, password: password);
            }
            else {
                createNewUser(email: email, password: password);
            }
        }
        
    }
    
    func createNewUser (email : String, password : String) {
        FIRAuth.auth()!.createUser(withEmail: email,password: password) { user, error in
            if error == nil {
                FIRAuth.auth()!.signIn(withEmail: email,password: password){ (user, error) in
                    let currentUserRef = self.usersOnlineRef.child((user?.uid)!);
                    currentUserRef.setValue(user?.email!)
                    currentUserRef.onDisconnectRemoveValue()
                    _ = self.navigationController?.popViewController(animated: true);
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
                _ = self.navigationController?.popViewController(animated: true);
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
