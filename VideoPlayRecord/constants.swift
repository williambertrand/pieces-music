//
//  constants.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 11/13/16.
//  Copyright © 2016 Ray Wenderlich. All rights reserved.
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
