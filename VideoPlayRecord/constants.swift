//
//  constants.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 11/13/16.
//  Copyright © 2016 Will Bert. All rights reserved.
//

import Foundation
import UIKit
import Firebase
let S3BucketName = "pieces-bucket";
var NEW_USER = false


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

func loginFirebaseUser(email: String, password: String){
    FIRAuth.auth()!.signIn(withEmail: email, password: password) { (user, error) in
        //enable watch and record buttons
        if user != nil {
        }
    }
}



//if auth!.hasTokenRefreshService {
//    self.renewTokenAndShowPlayer()
//    return
//}

//TODO - test this
func renewTokenAndShowPlayer() {
    //self.statusLabel.text = "Refreshing token..."
    SPTAuth.defaultInstance().renewSession(SPTAuth.defaultInstance().session) { error, session in
        SPTAuth.defaultInstance().session = session
        if error != nil {
      //      self.statusLabel.text = "Refreshing token failed."
            print("*** Error renewing session: \(error)")
            return
        }
        //self.showPlayer()
    }
}
