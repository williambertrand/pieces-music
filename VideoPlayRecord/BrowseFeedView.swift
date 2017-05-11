//
//  BrowseFeedView.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 4/18/17.
//  Copyright © 2017 Pieces. All rights reserved.
//

import Foundation
import UIKit
import AWSCore
import AWSS3

class BrowseFeedView : UIViewController, TransferDelegateViewController, UICollectionViewDelegate, UICollectionViewDataSource, SPTAudioStreamingDelegate {
    
    @IBOutlet weak var browseTitleLabel: UILabel!
    
    var titleText: String!
    var hrefForPieces: String!
    
    
    //Variables needed for creating the browse feed
    var transferDelegate : TransferDelegate!
    let feedCellIdentifier = "FEED_CELL"
    var feedCollectionView : UICollectionView!
    //all videos
    var downloadItems = [String]()
    var renderingItems = [PieceObj]()
    var fileNameToFilePathDict = [String: String]()
    var dict = NSDictionary()
    
    //spotify player
    var sptPlayer : SPTAudioStreamingController!
    
    var isPlayingMusic: Bool!
    var currentPlayingMusicIndex: Int!
    
    var playingMusicTitleView : PieceMusicPlayingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transferDelegate = TransferDelegate();
        transferDelegate.delegate = self;
        
        //TODO: change to getting specefic type of Piece
        transferDelegate.getAllPieces();
        
        let height = self.view.frame.height;
        let width = self.view.frame.width;
        self.browseTitleLabel.text = self.titleText
        
        let feedFrame = CGRect(x: 0, y: self.view.frame.height * 0.0775, width: self.view.frame.width, height: self.view.frame.height * 0.9);
        let feedLayout = UICollectionViewFlowLayout()
        feedLayout.itemSize = CGSize(width: self.view.frame.width, height: self.view.frame.height * 0.55);
        
        feedCollectionView = UICollectionView(frame: feedFrame, collectionViewLayout: feedLayout);
        feedCollectionView.backgroundColor = UIColor.white;
        feedCollectionView.register(WatchVideoCollectionViewCell.self, forCellWithReuseIdentifier: feedCellIdentifier);
        
        feedCollectionView.delegate = self
        feedCollectionView.dataSource = self
        
        self.view.addSubview(feedCollectionView);
        
        feedCollectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)));
        
        
        //set up the player
        self.sptPlayer = SPTAudioStreamingController.sharedInstance();
        self.sptPlayer.delegate = self;
        
        do {
            //try self.sptPlayer.start(withClientId: Spotify_Auth.clientID)
            self.sptPlayer.login(withAccessToken: Spotify_Auth.session.accessToken);
            print("AT:");
            print(Spotify_Auth.session.accessToken);
        }
        catch _ {
            let alert = UIAlertController(title: "Issue Creating Spotfy Connection", message: "Please re log in to Spotify", preferredStyle: .alert);
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                //_ = self.navigationController?.popViewController(animated: true);
            })
            alert.addAction(okAction);
            present(alert, animated: true, completion: nil);
        }
        
        isPlayingMusic = false;
        
        self.playingMusicTitleView = PieceMusicPlayingView(frame: CGRect.zero);
        self.playingMusicTitleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedSongView)))
        
        
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    //TransferDelegate delegate methods
    func appendToDownloadedItems(filePath: String) {
        self.downloadItems.append(filePath);
        //self.renderingItems.append(filePath);
        //self.feedCollectionView.reloadData();
        
        if self.renderingItems.count > 4 {
            DispatchQueue.main.async {
                self.feedCollectionView.reloadData()
            }
        }
    }
    
    func appendToDownloadedPieces(fileName: String, filePath: String) {
        self.fileNameToFilePathDict[fileName] = filePath;
        DispatchQueue.main.async {
            self.feedCollectionView.reloadData()
        }
        
    }
    
    func appendToDownloadedPieces(pieceObj: PieceObj) {
        self.renderingItems.append(pieceObj);
        if self.renderingItems.count > 0 {
            DispatchQueue.main.async {
                self.feedCollectionView.reloadData()
            }
        }
    }
    
    //UICollectionView Methods
    func indexOfDownloadRequest(_ array: Array<AWSS3TransferManagerDownloadRequest?>, downloadRequest: AWSS3TransferManagerDownloadRequest?) -> Int? {
        for (index, object) in array.enumerated() {
            if object == downloadRequest {
                return index
            }
        }
        return nil
    }
    
    // Setting up collection view
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: feedCellIdentifier, for: indexPath) as! WatchVideoCollectionViewCell;
        
        let piec = renderingItems[indexPath.row]
        cell.setPiece(piece: piec);
        
        
        //check to see if the cell has a downloaded video associated with it
        if self.fileNameToFilePathDict[piec.fileName] != nil {
            cell.addVideo(downloadFilePath: self.fileNameToFilePathDict[piec.fileName]!);
        }
        else {
            cell.showTemporaryVideo();
        }
        
        return cell;
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return renderingItems.count;
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:self.view.frame.width, height:self.view.frame.height * 0.4);
    }
    
    //register taps for the song playing view
    func tappedSongView(sender: UITapGestureRecognizer){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller : SongDetailViewController = storyboard.instantiateViewController(withIdentifier: "SongDetailViewControllerInstance") as! SongDetailViewController
        controller.selectedPieceObj = self.renderingItems[currentPlayingMusicIndex];
        self.present(controller, animated: true, completion: nil)
    }
    
    //register taps for the collectionview
    func tap(sender: UITapGestureRecognizer){
        
        self.stopPlayingSong();
        
        if let indexPath = self.feedCollectionView?.indexPathForItem(at: sender.location(in: self.feedCollectionView)) {
            let cell : WatchVideoCollectionViewCell = feedCollectionView.cellForItem(at: indexPath) as! WatchVideoCollectionViewCell;
            self.playSpotifySong(uri: renderingItems[indexPath.row].spotifyTrackURI, atIndex:indexPath.row); //TODO - spotify vs apple music
            
            //TODO: fix the lag here
            let when = DispatchTime.now() + 1.3
            DispatchQueue.main.asyncAfter(deadline: when) {
                cell.playVideo();
            }
            
        } else {
            print("feed view was tapped")
        }
    }
    
    //MARK SpotifyPlayer Section
    
    func playSpotifySong(uri: String, atIndex: Int){
        
        if(self.isPlayingMusic == true) {
            if(atIndex == currentPlayingMusicIndex){
                //stop the song
                try! self.sptPlayer.stop();
                self.isPlayingMusic = false;
                self.currentPlayingMusicIndex = -1;
            }
            self.currentPlayingMusicIndex = atIndex;
        }
        else {
            //add the music title view to the view
            self.currentPlayingMusicIndex = atIndex;
            addPlayingSongView();
            self.playingMusicTitleView.songLabel.text = self.renderingItems[currentPlayingMusicIndex].songTitle;
            //let songId = self.renderingItems[currentPlayingMusicIndex].spotifyTrackID;
            let sptUrl: URL = NSURL(string:self.renderingItems[currentPlayingMusicIndex].spotifyTrackURI!)! as URL
            self.getSongInfo(trackUrl: sptUrl);
            showPlayingSongView(width: self.view.frame.width, height: self.view.frame.height);
            
        }
        
        self.sptPlayer.playSpotifyURI(uri, startingWith: 0, startingWithPosition: 0) { (error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "error is nil");
            }
            
        }
    }
    
    
    
    func stopPlayingSong(){
        
    }
    
    func addPlayingSongView(){
        self.view.addSubview(playingMusicTitleView);
        
    }
    
    func showPlayingSongView(width: CGFloat, height: CGFloat){
        self.playingMusicTitleView.frame = CGRect(x: width * 0.02, y: height * 1.01, width: width * 0.35, height: height * 0.12);
        let bottomLeftCornerFrame = CGRect(x: width * 0.02, y: height * 0.85, width: width * 0.35, height: height * 0.12);
        UIView.animate(withDuration: 0.5, animations: {
            self.playingMusicTitleView.frame = bottomLeftCornerFrame;
        }, completion:{ (comp) in
            //add a little spinner or something
        });
    }
    
    let baseURL = "https://api.spotify.com";
    
    func getSongInfo(trackUrl: URL){
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
                    let artist = track.artists[0] as! SPTPartialArtist;
                    
                    DispatchQueue.main.async {
                        self.playingMusicTitleView.artistLabel.text = artist.name;
                    }
                    
                    //self.updateplayerAlbumImage(sptAlbum: album!);
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

    
    //TODO

    func appendToAdvertisingPieces(pieceObj: PieceObj){
        
    }
    func appendToDownloadedAdvertisingPieces(fileName: String, filePath: String){
        
    }
    
    
    
    
}
