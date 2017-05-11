//
//  ConnectServicesViewController.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 4/4/17.
//  Copyright © 2017 Pieces. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Firebase

var GLOBAL_spotifyAuthViewController : UIViewController!;
var GLOBAL_player: SPTAudioStreamingController!

class ConnectServicesViewController : UIViewController, SPTAudioStreamingDelegate {
    
    @IBOutlet weak var servicesTitleLabel: UILabel!

    @IBOutlet weak var doneButton: UIButton!
    //spotify authorization variables
    var spotifyAuth : SPTAuth!
    var player: SPTAudioStreamingController!
    var spotifyAuthViewController: UIViewController!
    
    var sptButton : UIButton!
    var appButton: UIButton!
    
    var NUM_SERVICES = 0;
    
    var ref: FIRDatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        let width = self.view.frame.width;
        let height = self.view.frame.height;
        
        //Check for connected service first
        //add Spotify button
        addSpotifyButton(width: width, height: height);
        addAppleMusicButton(width: width, height: height)
        self.ref = FIRDatabase.database().reference(withPath: "user-service-data")
        //addAppleMusicButton todo
        
    }
    
    func addSpotifyButton(width:CGFloat, height:CGFloat){
        let buttonRect = CGRect(x: width * 0.2, y: height * 0.45, width: width * 0.6, height: height * 0.1);
        sptButton = UIButton(frame: buttonRect);
        sptButton.setTitle("Connect Spotify", for: []);
        sptButton.setTitleColor(UIColor.white, for: []);
        sptButton.layer.cornerRadius = 4;
        sptButton.layer.backgroundColor = SPT_COLOR.cgColor;
        
        sptButton.addTarget(self, action: #selector(ConnectServicesViewController.connectSpotify), for: .touchUpInside);
        self.view.addSubview(sptButton);
    }
    
    func addAppleMusicButton(width:CGFloat, height:CGFloat){
        let buttonRectApp = CGRect(x: width * 0.2, y: height * 0.60, width: width * 0.6, height: height * 0.1);
        appButton = UIButton(frame: buttonRectApp);
        appButton.setTitle("Connect Apple Music", for: []);
        appButton.setTitleColor(UIColor.white, for: []);
        appButton.layer.cornerRadius = 4;
        appButton.layer.backgroundColor = APPL_MUSIC_COLOR.cgColor;
        appButton.isEnabled = false
        //appButton.addTarget(self, action: #selector(ConnectServicesViewController.connectSpotify), for: .touchUpInside);
        self.view.addSubview(appButton);
        
    }
    
    func connectSpotify(){
        
        print("Connecting Spotify");
        
        self.spotifyAuth = SPTAuth.defaultInstance()
        self.player = SPTAudioStreamingController.sharedInstance()
        self.spotifyAuth.clientID = "a3182e47b76c46419d84bcf1c709a218";
        self.spotifyAuth.redirectURL = URL(string:"pieces-audio-login://callback");
        self.spotifyAuth.sessionUserDefaultsKey = "current session"
        self.spotifyAuth.requestedScopes = [SPTAuthStreamingScope, SPTAuthUserReadPrivateScope, SPTAuthUserLibraryReadScope, SPTAuthUserFollowReadScope, SPTAuthUserReadTopScope];
        
        self.player.delegate = self;
        GLOBAL_player = self.player;
        do {
            try self.player.start(withClientId: self.spotifyAuth.clientID);
            
        } catch _ {
            print("ERROR CONNECTING TO SPORIFY");
        }
        
        Spotify_Auth = self.spotifyAuth;
        print("in app delegate!!!!!!!");
        
        DispatchQueue.main.async {
            self.startAuthenticationFlowForSpotify()
        }
        
        if(Spotify_Auth != nil && Spotify_Auth.session != nil){
            print("==========================");
            print("Acess Token: ");
            print(Spotify_Auth.session.accessToken);
            print(Spotify_Auth.tokenRefreshURL)
            //Spotify_Auth.session.encryptedRefreshToken
            let date = NSDate()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
            let nowDate = dateFormatter.string(from:date as Date)
            let obj = ["spt-token": Spotify_Auth.session.accessToken, "app-token":"none", "spt-connected-date": nowDate];
            ref.child((FIRAuth.auth()?.currentUser?.uid)!).setValue(obj);
            print("==========================");
        }
        
        //post to backend for getting a refresh
        self.createRefreshToken();
    }
    
    func createRefreshToken(){
        let tokenUrl = "https://peaceful-dawn-25448.herokuapp.com/token/swap"
        let params = ["code": Spotify_Auth.session.accessToken];
        Alamofire.request(tokenUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["content-type": "application/json"]).responseJSON { response in
            if(response.result.error != nil){
                //Error getting followers
                print("Error Getting refresh token: " + response.result.error.debugDescription);
            }
            
        }
    }
    
    func startAuthenticationFlowForSpotify(){
        if self.spotifyAuth.session == nil {
        }
        else if self.spotifyAuth.session.isValid() {
            print("Session was Valid **********");
            self.player.login(withAccessToken: self.spotifyAuth.session.accessToken);
            return;
        }
        else {
            //TODO -> POST https://accounts.spotify.com/api/token
            
        }
        
        
        let urlAuth = self.spotifyAuth.spotifyWebAuthenticationURL()
        self.spotifyAuthViewController = SFSafariViewController.init(url: urlAuth!);
        GLOBAL_spotifyAuthViewController = self.spotifyAuthViewController;
        self.present(self.spotifyAuthViewController, animated: true, completion: nil);
    }
    
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        
        //get Spotfy Account TODO
        let name = self.getSpotifyAccountUserName();
        print(" **************************************** ")
        print(" ")
        print("Succesfully Logged in to Spotify :\(name)")
        print("Access Token: ")
        print(self.spotifyAuth.session.accessToken);
        Spotify_Auth = self.spotifyAuth
        
        
        self.saveSpotifyTokenToFB(token: self.spotifyAuth.session.accessToken);
        
        sptButton.removeFromSuperview();
        self.NUM_SERVICES += 1;
        self.servicesTitleLabel.text = "Services Connected:"
        self.addConnectedServiceLabel(title: "Spotify: \(self.spotifyAuth.session.canonicalUsername!)");
        self.performAllSpotifyCollection();
        
    }
    
    
    func saveSpotifyTokenToFB(token : String){
        
    }
    
    func addConnectedServiceLabel(title: String){
        let labelRect = CGRect(x: self.view.frame.width * 0.05, y: self.servicesTitleLabel.center.y + (CGFloat(NUM_SERVICES) * self.view.frame.height * 0.1), width: self.view.frame.width * 0.4, height: self.view.frame.height * 0.1);
        let serviceLabel = UILabel(frame: labelRect);
        serviceLabel.font = UIFont(descriptor: UIFontDescriptor.init(name: "Helvetica", size: 14), size: 14);
        serviceLabel.text = title;
        serviceLabel.textColor = UIColor.darkGray;
        
        let removeRect = CGRect(x: self.view.frame.width * 0.83, y: self.servicesTitleLabel.center.y - 5 + (CGFloat(NUM_SERVICES) * self.view.frame.height * 0.1), width: self.view.frame.width * 0.15, height: self.view.frame.height * 0.1);
        let removeButton = UIButton(frame: removeRect);
        removeButton.setTitle("Remove", for: []);
        removeButton.setTitleColor(UIColor.darkGray, for: []);
        removeButton.titleLabel?.font = UIFont(descriptor: UIFontDescriptor.init(name: "Helvetica", size: 12), size: 12);
        
        self.view.addSubview(removeButton);
        self.view.addSubview(serviceLabel);
        
        Current_Services.append(title);
        
    }
    
    func getSpotifyAccountUserName() -> String {
        let params = ["Authorization": "\(self.spotifyAuth.session.accessToken)"];
        let spotifyInfoUrl = "https://api.spotify.com/v1/me";
        let result = Alamofire.request(spotifyInfoUrl, method: .get, parameters: params, encoding: JSONEncoding.default, headers: ["content-type":"application/json"]).response { (res) in
            //Get user ID here
            print(res);
        }
        return self.spotifyAuth.session.canonicalUsername;
    }
    
    
    //TODO
    let piecesCollectSPTURL = "https://peaceful-dawn-25448.herokuapp.com/spt/collect";
    let piecesCollectArtistsSPTURL = "https://peaceful-dawn-25448.herokuapp.com/api/spt/collect-artists";
    let piecesCollectAllSPTURL = "https://peaceful-dawn-25448.herokuapp.com/api/spt/collect-all";
    
    func performSpotifyArtistCollection(){
        let params = ["accessToken": Spotify_Auth.session.accessToken, "userID": Current_User.uid];
        let _ = Alamofire.request(piecesCollectArtistsSPTURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["content-type":"application/json"])
        
    }
    
    func performAllSpotifyCollection(){
        print("Current User: " + Current_User.uid);
        print("+++++++++++++++++++++++++++++");
        let params = ["accessToken": Spotify_Auth.session.accessToken, "userID": Current_User.uid];
        let _ = Alamofire.request(piecesCollectAllSPTURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["content-type":"application/json"])
        
    }
    
    @IBAction func donePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
    }
    
}
