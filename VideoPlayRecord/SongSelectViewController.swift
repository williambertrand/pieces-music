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
    var serviceUri: URL!
    var artistsIDs: [String]!
    var artistsURIs: [URL]!
    var album: String!
    var albumArtwork: String!
}


class SongSelectViewController : UIViewController, SPTAudioStreamingDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    //TODO
    let currentServiceType = MusicServiceType.spotify;
    
    let TRACK_RESULT = "trackResultCell";
    var added : Bool = false;
    
    var player: SPTAudioStreamingController!
    
    let searchURL = "https://api.spotify.com/v1/search"
    var searchQuery: String!
    
    var searchResults : SPTListPage!
    var resultsTableView : UITableView!
    var musicResults : [MusicTrack]!
    
    let SONG_TO_CAMERA = "SongToCameraSeque";
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var inPieceMakingProcess: Bool = false
    
    var currentPieceObject : PieceObj!
    var transferDelegate : TransferDelegate!
    
    //spotify player
    var sptPlayer : SPTAudioStreamingController!
    
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
        
        //set up the player
        self.sptPlayer = SPTAudioStreamingController.sharedInstance();
        self.sptPlayer.delegate = self;
        
        do {
            //try self.sptPlayer.start(withClientId: Spotify_Auth.clientID)
            self.sptPlayer.login(withAccessToken: Spotify_Auth.session.accessToken);
        }
        catch _ {
            let alert = UIAlertController(title: "Issue Creating Spotfy Connection", message: "Please re log in to Spotify", preferredStyle: .alert);
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                _ = self.navigationController?.popToRootViewController(animated: false);
            })
            alert.addAction(okAction);
            present(alert, animated: true, completion: nil);
        }
        
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.musicResults.removeAll();
        DispatchQueue.main.async {
            self.resultsTableView.reloadData();
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
            //musicItem.serviceUri = i.uri;
            if i.isPlayable {
                musicItem.serviceUri = i.playableUri
            }
            //musicItem.serviceUri = i.playableUri
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
        return self.view.frame.height * 0.15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TRACK_RESULT) as! MusicTrackSearchResultCell;
        if(indexPath.row < musicResults.count) {
            cell.trackLabel.text = musicResults[indexPath.row].title;
            cell.addArtistNamesToCell(artists: musicResults[indexPath.row].artistsURIs)
        }
        else {
         cell.trackLabel.text = "loading...";
        }
        
        return cell;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if inPieceMakingProcess == true {
            let song = musicResults[indexPath.row];
            
            //set some more data for the current piece object
            self.currentPieceObject.serviceType = currentServiceType;
            
            if currentServiceType == .spotify {
                self.currentPieceObject.spotifyTrackID = song.serviceId
                self.currentPieceObject.spotifyTrackURI = song.serviceUri.absoluteString;
                self.currentPieceObject.title = song.title
            }
            else {
                self.currentPieceObject.appleMusicTrackID = song.serviceId
            }
            
            //go back to main view controller
            
            //present an alert: 
            
            let alert = UIAlertController(title: "Upload Piece :)", message: "Upload this video with \(song.title!)?", preferredStyle: .alert);
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.transferDelegate.uploadPieceObject(pieceObj: self.currentPieceObject);
                DispatchQueue.main.async {
                    //_ = self.navigationController?.popViewController(animated: true);
                    self.performSegue(withIdentifier:self.SONG_TO_CAMERA , sender: self);
                    //_ = UIViewController.dismiss(self);
                }
            });
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
                //cancel the upload
                //TODO
                DispatchQueue.main.async {
                    //_ = self.navigationController?.popViewController(animated: true);
                    self.performSegue(withIdentifier:self.SONG_TO_CAMERA , sender: self);
                }
            });
            alert.addAction(cancelAction);
            alert.addAction(yesAction);
            present(alert, animated: true, completion: nil);
            
        }
        else {
            //show some music info?
        }
    }
    
    //TODO: tap recognizer just like in feed view V1 so that when a cell is tapped the song's sample can be played
    func tap(sender: UITapGestureRecognizer){
        
        if let indexPath = self.resultsTableView.indexPathForRow(at: sender.location(in: self.resultsTableView)) {
            let cell : MusicTrackSearchResultCell = resultsTableView.cellForRow(at: indexPath) as! MusicTrackSearchResultCell;
            self.playSpotifySongSample(uri: musicResults[indexPath.row].serviceUri);
            
        } else {
            print("feed view was tapped")
        }
    }
    
    
    func playSpotifySongSample(uri: URL) {
        self.sptPlayer.playSpotifyURI(uri.absoluteString, startingWith: 0, startingWithPosition: 15) { (error) in
            if error != nil {
                print(error?.localizedDescription ?? "error is nil");
            }
            
        }
    }
    
    
    
    
}
