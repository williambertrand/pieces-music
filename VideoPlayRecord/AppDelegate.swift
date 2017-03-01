//
//  AppDelegate.swift
//  VideoPlayRecord
//
//  Created by Andy (Test) on 1/31/15.
//  Copyright (c) 2015 Will Bert. All rights reserved.
//

import UIKit
import AWSCore
import AWSS3
import Firebase
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SPTAudioStreamingDelegate {

    var window: UIWindow?
    
    
    //spotify authorization variables
    var spotifyAuth : SPTAuth!
    var player: SPTAudioStreamingController!
    var spotifyAuthViewController: UIViewController!
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FIRApp.configure();
        // Override point for customization after application launch.
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USWest2, identityPoolId: "us-west-2:4c8c744b-acc8-43e4-9ba4-c7617706021a")
        //credentialProvider = AWSCognitoCredentialsProvider(regionType: .usWest2, identityPoolId: "us-west-2:4fac83eb-e629-4563-96ab-32a3dd3e1cfd")
        let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
        //AWSS3.register(with: configuration!, forKey: "USWest2S3");
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        self.spotifyAuth = SPTAuth.defaultInstance()
        self.player = SPTAudioStreamingController.sharedInstance()
        self.spotifyAuth.clientID = "a3182e47b76c46419d84bcf1c709a218";
        self.spotifyAuth.redirectURL = URL(string:"pieces-audio-login://callback");
        self.spotifyAuth.sessionUserDefaultsKey = "current session"
        self.spotifyAuth.requestedScopes = [SPTAuthStreamingScope, SPTAuthUserReadPrivateScope];
        
        self.player.delegate = self;
        
        do {
         try self.player.start(withClientId: self.spotifyAuth.clientID);
        
        } catch _ {
            print("ERROR CONNECTING TO SPORIFY");
        }
        
        DispatchQueue.main.async {
            self.startAuthenticationFlowForSpotify()
        }
        
        return true
    }
    
    //tODO: figure out session renewal
    
    func startAuthenticationFlowForSpotify(){
        if self.spotifyAuth.session == nil {
        }
        else if self.spotifyAuth.session.isValid() {
            print("Session was Valid **********")
            self.player.login(withAccessToken: self.spotifyAuth.session.accessToken);
            return;
        }
        else {
            
        }
        
        let urlAuth = self.spotifyAuth.spotifyWebAuthenticationURL()
        self.spotifyAuthViewController = SFSafariViewController.init(url: urlAuth!);
        self.window?.rootViewController?.present(self.spotifyAuthViewController, animated: true, completion: nil);
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if self.spotifyAuth.canHandle(url) {
            //close auth window
            self.spotifyAuthViewController.presentingViewController?.dismiss(animated: true, completion: nil);
            self.spotifyAuthViewController = nil;
            // Parse the incoming url to a session object
            self.spotifyAuth.handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) in
                if session != nil {
                    self.player.login(withAccessToken: self.spotifyAuth.session.accessToken);
                }
            });
            return true;
        }
        return false;
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        
        //get Spotfy Account TODO
        let name = self.getSpotifyAccountUserName();
        print(" **************************************** ")
        print(" ")
        print("Succesfully Logged in to Spotify :\(name)")
        print(self.spotifyAuth.session.accessToken);
        print(" ")
        print(" **************************************** ")
        Spotify_Auth = self.spotifyAuth
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
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

