//
//  UserObject.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 3/22/17.
//  Copyright © 2017 Pieces. All rights reserved.
//

import Foundation


enum UserType {
    case Artist
    case User
    case Advertiser
}


class UserObject: NSObject {
    
    //name, email, image, userid, numposts, numfollowers, numfollowing
    
    
    var name: String!
    var email: String!
    var image: UIImage!
    var type: UserType!
    
    var numPosts: Int!
    var numFollowers: Int!
    var numFollowing: Int!
    
    //used for finding
    var userId: String!
    
    var musicData: NSDictionary = NSDictionary()
    
    
    init(dict: NSDictionary) {
        self.name = dict["name"] as! String
        self.userId = dict["user_id"] as! String
        
        if let em = dict["email"] {
            self.email = em as! String;
        }
        
        if let type = dict["type"] {
            if(type as! String == "user") {
             self.type = UserType.User
            }
        }
        
        if let numPosts = dict["post_count"]{
            self.numPosts = numPosts as! Int
        }
        if let numFollowers = dict["follower_count"]{
            self.numFollowers = numFollowers as! Int
        }
        if let numFollowing = dict["following_count"]{
            self.numFollowing = numFollowing as! Int
        }
        
        if let musicPref = dict["musicPref"]{
            musicData = musicPref as! NSDictionary
        }
    }
    
}
