//
//  UserProfileViewController.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 4/30/17.
//  Copyright © 2017 Pieces. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class UserProfileViewController:UIViewController{
    
    //labels and such
    let ref: FIRDatabaseReference = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().reference()
    var user: UserObject!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var favoriteArtistLabel: UILabel!
    @IBOutlet weak var favoriteGenreLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var previewPieces: PiecesPreviewCollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getInfoFromFirebase();
        let piecesFrame = CGRect(x: 0, y: self.view.frame.height * 0.53, width: self.view.frame.width, height: self.view.frame.height * 0.47)
        self.previewPieces = PiecesPreviewCollectionView(frame: piecesFrame);
        self.view.addSubview(previewPieces);
        self.previewPieces.getPiecesForUser(userId: user.userId)
        self.previewPieces.layoutSubviews()
        
    }
    
    
    
    
    //TODOTODOTODOTODO follow relationship
    @IBAction func addFriendPressed(_ sender: Any) {
    }
    //
    @IBAction func closePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil);
    }
    
    func getInfoFromFirebase(){
        if(self.user == nil){
            print("User object for profile view not set!!!");
            return
        }
        self.userNameLabel.text = self.user.name
        self.emailLabel.text = self.user.email;
        self.getUserProfileImage()
        
        
        ref.child("public-user-data").child(self.user.userId!).observeSingleEvent(of: .value, with: { (snapshot) in
            let userDict = snapshot.value as! NSDictionary
            if let userG = userDict["top-genre"] {
                self.favoriteGenreLabel.text = userG as? String
            }
            if let userA = userDict["top-artist"] {
                self.favoriteArtistLabel.text = userA as? String
            }
            
        })
        
    }
    
    func getUserProfileImage(){
        print("getting image for \(self.user.userId)")
        ref.child("userphotos").child(self.user.userId!).observeSingleEvent(of: .value, with: { (snapshot) in
            // check if user has photo
            if snapshot.hasChild("userPhoto"){
                // set image locatin
                let filePath = "userPhotos/\(self.user.userId!)/\("userPhoto")"
                // Assuming a < 10MB file, though you can change that
                self.storageRef.child(filePath).data(withMaxSize: 10*1024*1024, completion: { (data, error) in
                    
                    let userPhoto = UIImage(data: data!)
                    self.userImageView.image = userPhoto
                })
            }
        })
    }
    
    
    
}
