//
//  UserSearchResultCell.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 4/22/17.
//  Copyright © 2017 Pieces. All rights reserved.
//

import Foundation
import UIKit

class UserSearchResultCell : UITableViewCell{

    var userImage: UIImage!
    var userName: String!
    var userEmail: String!
    var userLocationDesc: String!
    var userID:String!
    
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    
    
    func refresh(){
        
    }
    
}
