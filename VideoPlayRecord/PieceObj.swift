//
//  PieceObj.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 3/1/17.
//  Copyright © 2017 Pieces. All rights reserved.
//

import Foundation


enum MusicServiceType {
    case spotify
    case appleMusic
    //....
}


class PieceObj : NSObject {
    
    //piece info
    var title: String!
    
    var piece_id:Int!
    
    //S3 info
    var fileName: String!
    var s3Bucket: String!
    
    //user and post info
    var postedBy: String!
    var postDate: NSDate!
    
    var songTitle: String!
    
    //music info
    var serviceType: MusicServiceType!
    
    //service info: Spotify
    var spotifyTrackID: String!
    
    var spotifyTrackURI: String!
    
    //service info: AM
    var appleMusicTrackID: String!
    
    
    //Metadata: 
    var durationMS: UInt!
    var fileSize: CGFloat!
    
    /* Takes dictionary with fields : title, file_name, bucket, as arguments */
    init(dict : NSDictionary) {
        self.title = dict["title"] as! String
        self.piece_id = dict["id"] as! Int
        self.fileName = dict["s3_file_name"] as! String
        self.s3Bucket = dict["bucket_name"] as! String
        self.postedBy = dict["posted_by"] as! String
        
        if dict["spt_track_uri"] != nil {
            print("fee ditem has spotify uri")
            self.spotifyTrackURI = dict["spt_track_uri"] as! String
        }
        if dict["spt_track_id"] != nil {
            self.spotifyTrackID = dict["spt_track_id"] as! String
        }
        if dict["song_title"] != nil {
            self.songTitle = dict["song_title"] as! String
        }
        //self.postDate = dict["created_at"] as! String TODO
    }
    
    init(user: String) {
        self.postedBy = user;
        //TODO
    }
    
    
}
