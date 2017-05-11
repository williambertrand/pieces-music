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
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    override init() {
        // Firebase Init
        FIRApp.configure()
    }
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //FIRApp.configure();
        // Override point for customization after application launch.
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USWest2, identityPoolId: "us-west-2:4c8c744b-acc8-43e4-9ba4-c7617706021a")
        //credentialProvider = AWSCognitoCredentialsProvider(regionType: .usWest2, identityPoolId: "us-west-2:4fac83eb-e629-4563-96ab-32a3dd3e1cfd")
        let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
        //configuration?.retryHandler.maxRetryCount = 0;
        //AWSS3.register(with: configuration!, forKey: "USWest2S3");
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    
        AWSLogger.default().logLevel = .verbose;
        
        print("in app delegate!!!!!!!");

        
        return true
    }
    
    //tODO: figure out session renewal
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let spotifyAuth = SPTAuth.defaultInstance()!
        
        print("------------ IN APPLICATION OPEN URL! ------------");
        print("original: \(url)")
        print("\n")
        
        if spotifyAuth.canHandle(url) {
            //close auth window
            GLOBAL_spotifyAuthViewController.presentingViewController?.dismiss(animated: true, completion: nil);
            //GLOBAL_spotifyAuthViewController = nil;
            // Parse the incoming url to a session object
            spotifyAuth.handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) in
                if session != nil {
                    GLOBAL_player.login(withAccessToken: spotifyAuth.session.accessToken);
                    print("Triggered: \(url)")
                    
                    
                }
                
                
            });
            return true;
        }
        return false;
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
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

