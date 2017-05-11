//
//  UserReference.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 2/22/17.
//  Copyright © 2017 Will Bert. All rights reserved.
//

import Foundation
import Firebase
import UIKit

struct User {
    
    let uid: String
    let email: String
    
    init(authData: FIRUser) {
        uid = authData.uid
        email = authData.email!
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
    
}


var Current_User: User!
var Spotify_Auth : SPTAuth!


var Current_Services : [String] = [String]()
