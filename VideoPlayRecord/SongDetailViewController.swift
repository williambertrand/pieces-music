//
//  SongDetailViewController.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 4/14/17.
//  Copyright © 2017 Pieces. All rights reserved.
//

import Foundation
import UIKit


class SongDetailViewController: UIViewController{
    
    var selectedPieceObj : PieceObj!
    var songSpotifyID : String!
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    
    @IBOutlet weak var albumArtImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        songTitleLabel.text = selectedPieceObj.songTitle;
        
        print("Song title: \(selectedPieceObj.songTitle)");
        print("Song uri: \(selectedPieceObj.spotifyTrackURI)");
        let sptUrl: URL = NSURL(string:selectedPieceObj.spotifyTrackURI!)! as URL
        self.getTrackInfo(trackUrl: sptUrl);
        
        
    }
    @IBAction func followArtistPressed(_ sender: Any) {
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil);
    }
    
    @IBOutlet weak var findMorePressed: UIButton! //oops
    

    
    
    func updateAlbumImage(sptAlbum: SPTPartialAlbum){
        print("largesT:  width: \(sptAlbum.largestCover.size.width) url: \(sptAlbum.largestCover.imageURL!)")
        let imgURL = sptAlbum.largestCover.imageURL!;
        let session = URLSession(configuration: .default);
        //let imgURL = URL(string: imageUrlStr)!
        let downloadAlbumTask = session.dataTask(with: imgURL) { (data, response, error) in
            
            if let e = error {
                print("Error downloading album picture: \(e)")
            }
            else {
                print("checking response: \(data)");
                if let res = response as? HTTPURLResponse {
                    print("in response section");
                    if let imageData = data {
                        let image = UIImage(data: imageData);
                        DispatchQueue.main.async {
                            self.albumArtImageView.image = image;
                        }
                    }
                }
                
            }
            
        }
        //actually perform the task
        downloadAlbumTask.resume()
        
    }
    
    func getTrackInfo(trackUrl: URL){
        do {
            let trackReq = try SPTTrack.createRequest(forTrack: trackUrl, withAccessToken: Spotify_Auth.session.accessToken, market: nil);
            SPTRequest.sharedHandler().perform(trackReq) { (err, resp, data) in
                if(err != nil) {
                    print("ERROR: \(err.debugDescription)");
                }
                do {
                    
                    let track = try SPTTrack.init(from: data, with: resp)
                    
                    //let res:SPTListPage = try SPTTrack.tracks(from: data, with: resp) as! SPTListPage
                    
                    //let track: SPTTrack = res.items.first as! SPTTrack
                    print("Track: \(track)")
                    let artist = track.artists[0] as! SPTPartialArtist;
                    self.artistNameLabel.text = artist.name;
                    
                    let album = track.album
                    self.albumNameLabel.text = album?.name;
                    
                    self.updateAlbumImage(sptAlbum: album!);
                
                    
                }
                catch _ {
                    print("Caught Exception:");
                }
                
                
                
                
            }
            
        }
        catch _ {
            print("Error getting track info in song detail view");
        }
        
        
    }
    
}
