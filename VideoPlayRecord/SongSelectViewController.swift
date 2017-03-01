//
//  SongSelectViewController.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 2/25/17.
//  Copyright © 2017 Pieces. All rights reserved.
//

import Foundation
import UIKit

//need a global session object


//need a music track object


class MusicTrack {
    var title: String!
    var service: String!
    var serviceId: String!
    var artistsIDs: [String]!
    var artistsURIs: [URL]!
    var album: String!
    var albumArtwork: String!
}


class SongSelectViewController : UIViewController, SPTAudioStreamingDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let TRACK_RESULT = "trackResultCell";
    var added : Bool = false;
    
    var player: SPTAudioStreamingController!
    
    let searchURL = "https://api.spotify.com/v1/search"
    var searchQuery: String!
    
    var searchResults : SPTListPage!
    var resultsTableView : UITableView!
    var musicResults : [MusicTrack]!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        navigationController?.setNavigationBarHidden(true, animated: false);
        searchBar.delegate = self;
        musicResults = [MusicTrack]()
        resultsTableView = UITableView()
        
        //set up frame
        let tableViewFrame = CGRect(x: 0, y: searchBar.frame.height + self.view.frame.height * 0.05, width: self.view.frame.width, height: self.view.frame.height - searchBar.frame.height);
        resultsTableView.frame = tableViewFrame;
        resultsTableView.delegate = self;
        resultsTableView.dataSource = self;
        resultsTableView.separatorStyle = .none;
        resultsTableView.register(MusicTrackSearchResultCell.self, forCellReuseIdentifier: TRACK_RESULT)
        
        searchBar.placeholder = "Search For A Song..."
    }
    
    
    //Search Stuff
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.musicResults.removeAll();
        self.searchQuery = searchText;
        searchSpotifyForTrack(query: searchText);
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if self.added == false {
            self.view.addSubview(resultsTableView);
            self.added = true
        }
    }
    
    
    func parseSearchResults(){
        //add table and such
        if self.searchResults.items == nil {
            return;
        }
        for item in self.searchResults.items {
            let i = item as! SPTPartialTrack;
            let musicItem = MusicTrack()
            musicItem.title = i.name;
            //musicItem.artist = i.artists TODO
            musicItem.service = "Spotify"
            musicItem.serviceId = i.identifier;
            musicItem.artistsURIs = [URL]()
            musicItem.artistsIDs = [String]();
            for a in (i.artists as! [SPTPartialArtist]) {
                let artistName: String = a.identifier!;
                let artistURI = a.uri!;
                musicItem.artistsIDs.append(artistName);
                musicItem.artistsURIs.append(artistURI);
            }
            
            self.musicResults.append(musicItem);
            DispatchQueue.main.async {
                self.resultsTableView.reloadData();
            }
        }
    }
    
    func searchSpotifyForTrack(query: String){
        
        SPTSearch.perform(withQuery: query, queryType: .queryTypeTrack, accessToken: Spotify_Auth.session.accessToken, callback: { (error, tracks) in
            if error != nil {
                print("GOT AN ERROR: \(error?.localizedDescription)");
            }
            else {
                self.searchResults = tracks as! SPTListPage
                print("done");
                self.parseSearchResults()
            }
        });
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //self.searchSpotifyForTrack(query: self.searchQuery);
        self.dismissKeyboard();
    }
    
    
    //End Search Stuff
    
    
    //UITableViewStuff
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.musicResults.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height * 0.1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TRACK_RESULT) as! MusicTrackSearchResultCell;
        cell.trackLabel.text = musicResults[indexPath.row].title;
        cell.addArtistNamesToCell(artists: musicResults[indexPath.row].artistsURIs)
        return cell;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    
    
    
    
}
