//
//  ProfileViewController.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 4/7/17.
//  Copyright © 2017 Pieces. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Firebase

class ProfileViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var addServiceButton: UIButton!
    
    @IBOutlet weak var ServiceSectionLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    var numServices : Int = 0;
    var serviceList : [String] = [String]()
    var ref: FIRDatabaseReference!
    var aboutMEButton: UIButton!
    
    var profileImageView: UIImageView!
    
    var profileImageUrlString: String!
    
    
    var uploadedPieces = 0;
    var numFollowers = 0;
    
    let databaseRef = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().reference()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        addServiceButton.layer.cornerRadius = 3
        addServiceButton.layer.backgroundColor = SPT_COLOR.cgColor
        addServiceButton.setTitleColor(UIColor.white, for: [])
        
        addProfileLabels(width:self.view.frame.width, height: self.view.frame.height);
        addAboutMeButton(width:self.view.frame.width, height: self.view.frame.height);
        
        let imageRect = CGRect(x: self.view.frame.width * 0.02, y: titleLabel.center.y + self.view.frame.height * 0.05, width: self.view.frame.width * 0.34, height: self.view.frame.height * 0.14);
        
        profileImageView = UIImageView(frame: imageRect);
        profileImageView.image = UIImage(named: "default-profile");
        profileImageView.contentMode = .scaleAspectFit;
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
        //profileImageView.layer.backgroundColor = UIColor.darkGray.cgColor
        self.view.addSubview(profileImageView);
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        profileImageView.isUserInteractionEnabled = true
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        self.showServices(width:self.view.frame.width, height: self.view.frame.height);
        self.getUserProfileImage();
        //self.getSpotifyProfileImage();
    }
    
    @IBAction func collectPressed(_ sender: Any) {
        self.performSpotifyCollection();
    }
    
    @IBAction func logoutWasPressed(_ sender: Any) {
        try! FIRAuth.auth()!.signOut()
        Current_User = nil;
        self.showSignInViewController()
    }
    
    func showSignInViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginSignupViewControllerInstance") as! LoginSignupViewController
        self.present(controller, animated: true, completion: nil)
    }
    
    let piecesCollectSPTURL = "https://peaceful-dawn-25448.herokuapp.com/spt/collect";
    let piecesCollectArtistsSPTURL = "https://peaceful-dawn-25448.herokuapp.com/api/spt/collect-artists";
    func performSpotifyCollection(){
        print("CALLING SERVER TO COLLECT");
        let params = ["accessToken": Spotify_Auth.session.accessToken, "userId": Current_User.uid];
        let _ = Alamofire.request(piecesCollectArtistsSPTURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["content-type":"application/json"])
        
    }
    
    func getServicesFromFirebase(){
        self.ref.child("user-services/\(Current_User.uid)").observe(FIRDataEventType.value, with: { (snapshot) in
            print("Services found: ");
            let res = snapshot.value! as! [String: String]
            //todp
//            for(serv in res.keys){
//                self.serviceList.append(res[serv]);
//            }
            self.showServices(width:self.view.frame.width, height: self.view.frame.height);
        })
        
        
    }
    
    //TODO
    func showServices(width: CGFloat, height: CGFloat){
        var i = 0;
        var serviceLabelY = height * 0.65;
        while(i < Current_Services.count){
            //Add service label
            let serviceFrame = CGRect(x: width * 0.04, y: serviceLabelY, width: width * 0.4, height: height * 0.1);
            let lab: UILabel = UILabel(frame: serviceFrame);
            lab.text = Current_Services[i];
            lab.font = UIFont(descriptor: UIFontDescriptor.init(name: "Helvetica", size: 14), size: 14);
            self.view.addSubview(lab);
            i = i + 1;
            serviceLabelY += height * 0.1;
        }
    }
    
    
    func addProfileLabels(width: CGFloat, height: CGFloat) {
        let labelRect = CGRect(x: width * 0.5, y: height * 0.015, width: width * 0.46, height: height * 0.1);
        let label = UILabel(frame: labelRect);
        label.font = UIFont(descriptor: UIFontDescriptor.init(name: "Helvetica", size: 14), size: 16);
        label.text = Current_User.email;
        label.textColor = UIColor.lightGray;
        label.textAlignment = .right
        self.view.addSubview(label);
        
        
        let labelRectNumPieces = CGRect(x: width * 0.04, y: height * 0.37, width: width * 0.5, height: height * 0.075);
        let piecesLabel = UILabel(frame: labelRectNumPieces);
        piecesLabel.font = UIFont(descriptor: UIFontDescriptor.init(name: "Helvetica", size: 14), size: 16);
        piecesLabel.text = "Your pieces: \(uploadedPieces)";
        piecesLabel.textAlignment = .left
        self.view.addSubview(piecesLabel);
        
        
        let buttRectMYPieces = CGRect(x: width * 0.54, y: height * 0.37, width: width * 0.4, height: height * 0.1);
        let myPiecesButt = UIButton(frame: buttRectMYPieces);
        //myPiecesButt = UIFont(descriptor: UIFontDescriptor.init(name: "Helvetica", size: 14), size: 16);
        myPiecesButt.setTitle("My Pieces", for: [])
        myPiecesButt.setTitleColor(UIColor.white, for: [])
        myPiecesButt.titleLabel?.font = UIFont(descriptor: UIFontDescriptor.init(name: "Helvetica", size: 14), size: 16);
        myPiecesButt.layer.backgroundColor = PRETTY_BLUE.cgColor
        myPiecesButt.layer.cornerRadius = 4;
        
        myPiecesButt.addTarget(self, action: #selector(ProfileViewController.showMyPiecesView), for: .touchUpInside)
        
        self.view.addSubview(myPiecesButt);
        
        
        let labelRectNumFollowers = CGRect(x: width * 0.04, y: height * 0.445, width: width * 0.5, height: height * 0.075);
        let followersLabel = UILabel(frame: labelRectNumFollowers);
        followersLabel.font = UIFont(descriptor: UIFontDescriptor.init(name: "Helvetica", size: 14), size: 16);
        followersLabel.text = "Your Followers: \(numFollowers)";
        followersLabel.textAlignment = .left
        self.view.addSubview(followersLabel);
    }
    
    func addAboutMeButton(width: CGFloat, height: CGFloat){
        let buttRect = CGRect(x: width * 0.04, y: height * 0.3, width: width * 0.35, height: height * 0.05);
        aboutMEButton = UIButton(frame: buttRect);
        //aboutMEButton.titleLabel?.font = UIFont(descriptor: UIFontDescriptor.init(name: "Helvetica", size: 14), size: 14);
        aboutMEButton.layer.cornerRadius = 4
        aboutMEButton.layer.backgroundColor = PRETTY_BLUE.cgColor;
        aboutMEButton.setTitleColor(UIColor.white, for: []);
        aboutMEButton.setTitle("My Music Taste", for: []);
        aboutMEButton.addTarget(self, action: #selector(ProfileViewController.showAboutMEView), for: .touchUpInside);
        self.view.addSubview(aboutMEButton);
    }
    
    func showAboutMEView(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AboutMeViewControllerInstance")
        self.present(controller, animated: true, completion: nil)
    }
    
    
    func showMyPiecesView(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PiecesGenericViewInstance") as! PiecesGenericListView
        controller.userID = Current_User.uid;
        self.present(controller, animated: true, completion: nil)
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL) {
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { () -> Void in
                print("Updating profile image")
                self.profileImageView.image = UIImage(data: data)
            }
        }
    }
    
    func getSpotifyProfileImage(){
        print("called get spotify proifile image")
        if(Spotify_Auth == nil){
            return;
        }
        if(Spotify_Auth.session == nil){
            return;
        }
        let params = ["Authorization": "Bearer \(Spotify_Auth.session.accessToken)"];
        let spotifyInfoUrl = "https://api.spotify.com/v1/me";
        Alamofire.request(spotifyInfoUrl, method: .get, parameters: params, encoding: JSONEncoding.default, headers: ["content-type":"application/json"]).responseJSON(completionHandler: { response in
            print(response.result)
            if(response.result.error != nil){
                //Error getting music dara
                print("Error Getting spt progile image: " + response.result.error.debugDescription);
                return;
            }
            

            if let data = response.result.value as! NSDictionary? {
                if(data["images"] != nil){
                    let respImageArr = data["images"] as! [NSDictionary]
                    let imageDict = respImageArr[0]
                    let imageUrl = imageDict["url"] as! String
                    print("Got image: \(imageUrl)")
                    let imgUrl = URL(string: imageUrl)!;
                    self.downloadImage(url: imgUrl);
                }
            }
        })
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.profileImageView.image = image
            dismiss(animated: true, completion: nil)
            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!) as NSData? {
                let filePath = "userPhotos/\(FIRAuth.auth()!.currentUser!.uid)/\("userPhoto")"
                storageRef.child(filePath).put(uploadData as Data, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error)
                        
                    } else {
                        print("Image Uploaded Succesfully")
                        //let metaData = FIRStorageMetadata()
                        //metaData.contentType = "image/png"
                        let downloadURL = metadata?.downloadURL()!.absoluteString
                        //store downloadURL at database
                        self.databaseRef.child("userphotos").child(FIRAuth.auth()!.currentUser!.uid).updateChildValues(["userPhoto": downloadURL])
                    }  
                })
            }
            
        }
    }
    
    
    func getUserProfileImage(){
        databaseRef.child("userphotos").child(FIRAuth.auth()!.currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // check if user has photo
            if snapshot.hasChild("userPhoto"){
                // set image locatin
                let filePath = "userPhotos/\(FIRAuth.auth()!.currentUser!.uid)/\("userPhoto")"
                // Assuming a < 10MB file, though you can change that
                self.storageRef.child(filePath).data(withMaxSize: 10*1024*1024, completion: { (data, error) in
                    
                    let userPhoto = UIImage(data: data!)
                    self.profileImageView.image = userPhoto
                })
            }
        })
    }
    
    
    func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    
    
    
    
    
}

