//
//  AboutMeViewController.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 4/10/17.
//  Copyright © 2017 Pieces. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class AboutMeViewControler : UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    
    var artistsTableView: UITableView!
    var tracksTableView: UITableView!
    var genresTableView: UITableView!
    
    
    var genreList: [String] = [String]()
    var artistsList: [String] = [String]()
    var tracksList: [String] = [String]()
    
    
    var aboutMeScrollView: UIScrollView!
    
    
    var doneButton: UIButton!;
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        //add list of artists and genres
        aboutMeScrollView = UIScrollView(frame: CGRect(x: 0, y: self.view.frame.height * 0.1, width: self.view.frame.width, height: self.view.frame.height * 0.9));
        aboutMeScrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height * 2);
        
        
        let artistFrame = CGRect(x: 0, y: self.view.frame.height * 0.05, width: self.view.frame.width, height: self.view.frame.height * 0.35);
        artistsTableView = UITableView(frame: artistFrame);
        artistsTableView.delegate = self;
        artistsTableView.dataSource = self;
        artistsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "artistCell");
        
        let tracksFrame = CGRect(x: 0, y: self.view.frame.height * 0.45, width: self.view.frame.width, height: self.view.frame.height * 0.35);
        tracksTableView = UITableView(frame: tracksFrame);
        tracksTableView.delegate = self;
        tracksTableView.dataSource = self;
        tracksTableView.register(UITableViewCell.self, forCellReuseIdentifier: "trackCell");
        
        
        let genreFrame = CGRect(x: 0, y: self.view.frame.height * 0.85, width: self.view.frame.width, height: self.view.frame.height * 0.35);
        genresTableView = UITableView(frame: genreFrame);
        genresTableView.delegate = self;
        genresTableView.dataSource = self;
        genresTableView.register(UITableViewCell.self, forCellReuseIdentifier: "genreCell");
        
        //add title labels for each table view
        self.aboutMeScrollView.addSubview(artistsTableView);
        self.aboutMeScrollView.addSubview(tracksTableView);
        self.aboutMeScrollView.addSubview(genresTableView);
        
        
        self.view.addSubview(aboutMeScrollView);
        self.getUserMusicInfo(userId: Current_User.uid);
        self.addDoneButton(width: self.view.frame.width, height: self.view.frame.height);
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(tableView == self.genresTableView){
            return "My Genres";
        }
        else if(tableView == self.artistsTableView){
            return "My Artists";
        }
        else {
            return "My Tracks";
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.genresTableView){
            return genreList.count;
        }
        else if(tableView == self.artistsTableView){
            return artistsList.count;
        }
        else {
            return tracksList.count;
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        if(tableView == self.genresTableView){
            cell = tableView.dequeueReusableCell(withIdentifier: "genreCell");
            cell?.textLabel?.text = genreList[indexPath.row];
        }
        else if(tableView == self.artistsTableView){
            cell = tableView.dequeueReusableCell(withIdentifier: "artistCell");
            cell?.textLabel?.text = artistsList[indexPath.row];
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "trackCell");
            cell?.textLabel?.text = tracksList[indexPath.row];
        }
        
        return cell!;
    }
    
    let userMusicInfoUrl = "https://peaceful-dawn-25448.herokuapp.com/api/user/musicdata";
    func getUserMusicInfo(userId: String){
        let userIDMusicInfoUrl = "https://peaceful-dawn-25448.herokuapp.com/api/user/musicdata?userID=\(Current_User.uid)";
        let res = Alamofire.request(userIDMusicInfoUrl, method: .get).responseJSON(completionHandler: { response in
            
            if(response.result.error != nil){
                //Error getting music dara
                print("Error Getting music data: " + response.result.error.debugDescription);
                return;
            }
            
            
            if let data = response.result.value as! NSDictionary? {
                let genres = data["genres"] as! [String]
                self.genreList.append(contentsOf: genres);
                print("GENRE 1:" + genres.first!);
                
                let artists = data["artists"] as! [String]
                self.artistsList.append(contentsOf: artists);
                
                let tracks = data["tracks"] as! NSArray?
                
                for track in tracks! {
                    let t = track as! NSDictionary
                    let n = t["track"] as! String
                    let a = t["artist"] as! String
                    self.tracksList.append( n + " (" + a + ")");
                }
                
                DispatchQueue.main.async {
                    self.artistsTableView.reloadData()
                    self.genresTableView.reloadData()
                    self.tracksTableView.reloadData()
                }
                
            }
            
        
        });
        
    }
    
    
    func addDoneButton(width: CGFloat, height: CGFloat){
        let buttRect = CGRect(x: width * 0.785, y: height * 0.05, width: width * 0.2, height: height * 0.05);
        doneButton = UIButton(frame: buttRect);
        //aboutMEButton.titleLabel?.font = UIFont(descriptor: UIFontDescriptor.init(name: "Helvetica", size: 14), size: 14);
        doneButton.layer.cornerRadius = 4
        doneButton.setTitleColor(PRETTY_BLUE, for: []);
        doneButton.setTitle("Done", for: []);
        doneButton.addTarget(self, action: #selector(AboutMeViewControler.donePressed), for: .touchUpInside);
        self.view.addSubview(doneButton);
    }
    
    func donePressed(){
        self.presentingViewController?.dismiss(animated: true, completion: nil);
    }
    
    
    
    
}
