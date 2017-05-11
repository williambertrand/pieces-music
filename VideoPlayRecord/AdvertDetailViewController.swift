//
//  AdvertDetailViewController.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 4/23/17.
//  Copyright © 2017 Pieces. All rights reserved.
//

import Foundation
import UIKit

class AdvertDetailViewController: UIViewController{
    //TODO
    
    var selectedPieceObj : PieceObj!
    var songSpotifyID : String!
    
    
    @IBOutlet weak var advertImageView: UIImageView!
    
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var songTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        songTitleLabel.text = selectedPieceObj.songTitle;
        
        print("Song title: \(selectedPieceObj.songTitle)");
        print("Song uri: \(selectedPieceObj.spotifyTrackURI)");
        let sptUrl: URL = NSURL(string:selectedPieceObj.spotifyTrackURI!)! as URL
        self.getTrackInfo(trackUrl: sptUrl);
        
        self.advertImageView.image = UIImage(named: "pepsi-ad");
        self.advertImageView.layer.cornerRadius = 4
        
    }
    
    @IBAction func closePressed(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil);
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
                    
                    //self.updateAlbumImage(sptAlbum: album!);
                    
                    
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
