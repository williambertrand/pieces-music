//
//  PiecesPreviewCollectionView.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 4/30/17.
//  Copyright © 2017 Pieces. All rights reserved.
//

import Foundation
import UIKit


class PiecesPreviewCollectionView: UIView, TransferDelegateViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, SPTAudioStreamingDelegate {

    
    var piecesCollectionView: UICollectionView!
    
    var transferDelegate : TransferDelegate!
    var renderingItems = [PieceObj]()
    var loadCap: Int = 5;
    var fileNameToFilePathDict = [String: String]()
    
    var sptPlayer : SPTAudioStreamingController!
    var isPlayingMusic: Bool!
    
    var currentPlayingMusicIndex: Int!
    var playingMusicTitleView : PieceMusicPlayingView!
    
    
    
    let feedCellIdentifier = "piecesFeedCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        print("FRAME: ")
        print(frame);
        transferDelegate = TransferDelegate();
        transferDelegate.delegate = self
        
        let newLayout = UICollectionViewFlowLayout()
        newLayout.itemSize = CGSize(width: frame.width, height: frame.height * 0.75);
        let pFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height);
        self.piecesCollectionView = UICollectionView(frame:pFrame, collectionViewLayout: newLayout)
        piecesCollectionView.register(WatchVideoCollectionViewCell.self, forCellWithReuseIdentifier: feedCellIdentifier);
        piecesCollectionView.delegate = self
        piecesCollectionView.dataSource = self
        
        self.addSubview(piecesCollectionView);
        piecesCollectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)));
        
        self.sptPlayer = SPTAudioStreamingController.sharedInstance();
        self.sptPlayer.delegate = self;
        
        do {
            //try self.sptPlayer.start(withClientId: Spotify_Auth.clientID)
            self.sptPlayer.login(withAccessToken: Spotify_Auth.session.accessToken);
        }
        catch _ {
            print("error loggin in to spotify");
        }
        
        currentPlayingMusicIndex = -1;
        isPlayingMusic = false;
        self.backgroundColor = UIColor.lightGray;
        
        
    }
    
    func getPieces(query: String, param: String){
        
        if(query == "all"){
            self.transferDelegate.getAllPieces();
        }
        else if(query == "user"){
            self.transferDelegate.getPiecesForUser(userId: param, limit: 5)
        }
        
    }
    
    
    
    //Transferdelegate required methods: ===================================
    
    
    func appendToDownloadedPieces(fileName: String, filePath: String) {
        self.fileNameToFilePathDict[fileName] = filePath;
        print("APEENDING PIECE IN PREVIEW COLLECTION!!!!!!");
        DispatchQueue.main.async {
            self.piecesCollectionView.reloadData();
        }
    }
    
    
    func appendToDownloadedPieces(pieceObj: PieceObj) {
        if(renderingItems.count <= loadCap){
            self.renderingItems.append(pieceObj);
            transferDelegate.downloadPieceFromAwsBucket(piece: pieceObj);
        }
        else {
            //do nothing - only showing #load cap pieces
        }
    }
    
    func getPiecesForUser(userId: String){
        self.transferDelegate.getPiecesForUser(userId: userId, limit: 3);
    }
    
    //END ===================================
    
    
    
    
    //Collection view methods:
    
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if(renderingItems.count > loadCap){
            return loadCap;
        }
        else {
            return renderingItems.count;
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return renderingItems.count
    }

    
    
    
    func tap(sender: UITapGestureRecognizer){
        self.stopPlayingSong();
        
        if let indexPath = self.piecesCollectionView?.indexPathForItem(at: sender.location(in: self.piecesCollectionView)) {
            
                
                let cell : WatchVideoCollectionViewCell = piecesCollectionView.cellForItem(at: indexPath) as! WatchVideoCollectionViewCell;
                self.playSpotifySong(uri: renderingItems[indexPath.row].spotifyTrackURI, atIndex:indexPath.row); //TODO - spotify vs apple music
                
                //TODO: fix the lag here
                let when = DispatchTime.now() + 1.3
                DispatchQueue.main.asyncAfter(deadline: when) {
                    cell.playVideo();
                }
            
                
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
            self.playingMusicTitleView.songLabel.text = self.renderingItems[currentPlayingMusicIndex].songTitle;
            //let songId = self.renderingItems[currentPlayingMusicIndex].spotifyTrackID;
            let sptUrl: URL = NSURL(string:self.renderingItems[currentPlayingMusicIndex].spotifyTrackURI!)! as URL
            
        }
        
        self.sptPlayer.playSpotifyURI(uri, startingWith: 0, startingWithPosition: 0) { (error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "error is nil");
            }
            
        }
    }
    
    
    
    func stopPlayingSong(){
        
    }
    
    
    
    
    //rest of required methods
    func appendToDownloadedItems(filePath: String){}
    func appendToAdvertisingPieces(pieceObj: PieceObj){}
    func appendToDownloadedAdvertisingPieces(fileName: String, filePath: String){}
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
