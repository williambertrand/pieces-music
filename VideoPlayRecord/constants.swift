//
//  constants.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 11/13/16.
//  Copyright © 2016 Will Bert. All rights reserved.
//

import Foundation
import UIKit
let S3BucketName = "pieces-bucket";


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
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
