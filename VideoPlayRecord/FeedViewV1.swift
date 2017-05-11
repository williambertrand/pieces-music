//
//  FeedViewV1.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 2/9/17.
//  Copyright © 2017 Will Bert. All rights reserved.
//

import Foundation
import UIKit
import AWSCore
import AWSS3
import Firebase

class FeedViewV1 : UIViewController, TransferDelegateViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, SPTAudioStreamingDelegate {
    
    //all videos
    var downloadItems = [String]()
    var renderingItems = [PieceObj]()
    var orderedFileNames: [String] = [String]()
    
    var advertisingItems = [PieceObj]()
    
    var piecesToDownload = [PieceObj]()
    
    var fileNameToFilePathDict = [String: String]()
    var dict = NSDictionary()
    
    var showingAdvertView = false
    
    
    let userNamesRef = FIRDatabase.database().reference(withPath: "public-user-data")
    
    
    var transferDelegate : TransferDelegate!
    
    var currentPiecesDisplayCount: Int = 0;
    var loadCap: Int = 5;
    
    let feedCellIdentifier = "FEED_CELL"
    var feedCollectionView : UICollectionView!
    
    var currentFocusIndex : Int = -1 // track which view is currently focused
    
    var autoplayToggleButton : UIButton!;
    var autoplayOn : Bool = true
    
    
    //bar buttons
    
    
    var searchbutton: UIButton!
    var composeButton: UIButton!
    
    //spotify player
    var sptPlayer : SPTAudioStreamingController!
    
    var isPlayingMusic: Bool!
    var currentPlayingMusicIndex: Int!
    
    var playingMusicTitleView : PieceMusicPlayingView!
    var advertView: PiecesMusicAdvertView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationController?.setNavigationBarHidden(true, animated: false);
        // Do any additional setup after loading the view, typically from a nib.
        transferDelegate = TransferDelegate();
        transferDelegate.delegate = self
        
        //TODO: change the following line to transferDelegate.getPiecesFeedFor(user: Current_user.uid)
        self.getTestAdvertisement();
        transferDelegate.getAllPieces();
        let height = self.view.frame.height;
        let width = self.view.frame.width;
        
        //set up buttons
        let searchFrame = CGRect(x: self.view.frame.width * 0.02, y: self.view.frame.height * 0.02, width: self.view.frame.width * 0.08, height: self.view.frame.height * 0.065);
        let composeFrame = CGRect(x: self.view.frame.width * 0.88, y: self.view.frame.height * 0.02, width: self.view.frame.width * 0.1, height: self.view.frame.height * 0.08);
        self.searchbutton = UIButton(frame: searchFrame);
        self.composeButton = UIButton(frame: composeFrame);
        self.searchbutton.setImage(UIImage(named:"search-icon"), for: []);
        self.searchbutton.imageView?.contentMode = .scaleAspectFit;
        self.composeButton.setImage(UIImage(named:"compose-icon"), for: []);
        self.composeButton.imageView?.contentMode = .scaleAspectFit;
        self.searchbutton.addTarget(self, action: #selector(FeedViewV1.searchPressed), for: .touchUpInside);
        self.composeButton.addTarget(self, action: #selector(FeedViewV1.composePressed), for: .touchUpInside);
        //self.view.addSubview(searchbutton);
        //self.view.addSubview(composeButton);
        
        //add autoplay button ----- TODO
        
        let apFrame = CGRect(x: 0, y: height * 0.9, width: width * 0.2, height: height * 0.1);
        autoplayToggleButton = UIButton(frame: apFrame);
        autoplayToggleButton.setTitle("autoplay off", for: []);
        autoplayToggleButton.contentMode = .center;
        autoplayToggleButton.titleLabel?.font = UIFont(name: "Helvetica Nue", size: 14);
        autoplayToggleButton.titleLabel?.textColor = UIColor.darkGray;
        autoplayToggleButton.addTarget(self, action: #selector(FeedViewV1.toggleAutoPlay), for: .touchUpInside);
        
        
        let feedFrame = CGRect(x: 0, y: self.view.frame.height * 0.0775, width: self.view.frame.width, height: self.view.frame.height * 0.9);
        let feedLayout = UICollectionViewFlowLayout()
        feedLayout.itemSize = CGSize(width: self.view.frame.width, height: self.view.frame.height * 0.55);
        
        feedCollectionView = UICollectionView(frame: feedFrame, collectionViewLayout: feedLayout);
        feedCollectionView.backgroundColor = UIColor.white;
        feedCollectionView.register(WatchVideoCollectionViewCell.self, forCellWithReuseIdentifier: feedCellIdentifier);
        feedCollectionView.register(LoadMoreCollectionViewCell.self, forCellWithReuseIdentifier: "loadMoreCell");
        
        
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
        }
        catch _ {
            let alert = UIAlertController(title: "Issue Creating Spotfy Connection", message: "Please re log in to Spotify", preferredStyle: .alert);
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                //_ = self.navigationController?.popViewController(animated: true);
            })
            alert.addAction(okAction);
            present(alert, animated: true, completion: nil);
        }
        
        currentPlayingMusicIndex = -1;
        isPlayingMusic = false;
        
        self.playingMusicTitleView = PieceMusicPlayingView(frame: CGRect.zero);
        self.playingMusicTitleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedSongView)))
        
        self.advertView = PiecesMusicAdvertView(frame: CGRect.zero);
        self.advertView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedAdvertView)))
        self.view.addSubview(advertView);
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func appendToDownloadedItems(filePath: String) {
        self.downloadItems.append(filePath);
        //self.renderingItems.append(filePath);
        //self.feedCollectionView.reloadData();
        
//        if self.renderingItems.count > 4 {
//            DispatchQueue.main.async {
//                self.feedCollectionView.reloadData()
//            }
//        }
    }
    
    func appendToDownloadedPieces(fileName: String, filePath: String) {
        self.fileNameToFilePathDict[fileName] = filePath;
        //get index for the filename
        let p = getIndexRowForFile(fileName: fileName);
        if(p >= 0){
            let pat = IndexPath(row: p, section: 0);
            //UIView.setAnimationsEnabled(false);
            //self.feedCollectionView.reloadItems(at: [pat]);
            //UIView.setAnimationsEnabled(true);
        }
        
    }
    
    func getIndexRowForFile(fileName: String) -> Int{
        let x = orderedFileNames.index(of: fileName);
        if (x == nil){
            return -1;
        }
        else {
         return x!;
        }
    }
    
    func getTestAdvertisement(){
        let p = transferDelegate.getPieceForTestAdvert();
        self.advertisingItems.append(p);
        transferDelegate.downloadAdvertisingPieceFromAwsBucket(piece: p);
    }
    
    func appendToAdvertisingPieces(pieceObj: PieceObj){
        //self.advertisingItems.append(pieceObj);
        print("APPENDING ADVERTISEMENT PIECEOBJ");
        DispatchQueue.main.async {
            self.feedCollectionView.reloadData()
        }
    }
    
    func appendToDownloadedAdvertisingPieces(fileName: String, filePath: String){
        print("Downloaded Advertisement appended to pieces");
        self.fileNameToFilePathDict[fileName] = filePath;
        DispatchQueue.main.async {
            self.feedCollectionView.reloadData()
        }
    }
    
    
    
    func appendToDownloadedPieces(pieceObj: PieceObj) {
        if(renderingItems.count <= loadCap){
            self.renderingItems.append(pieceObj);
            self.orderedFileNames.append(pieceObj.fileName);
            transferDelegate.downloadPieceFromAwsBucket(piece: pieceObj);
        }
        else {
            self.piecesToDownload.append(pieceObj);
        }
    }
    
    
    
    //collection view stuff +++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    func indexOfDownloadRequest(_ array: Array<AWSS3TransferManagerDownloadRequest?>, downloadRequest: AWSS3TransferManagerDownloadRequest?) -> Int? {
        for (index, object) in array.enumerated() {
            if object == downloadRequest {
                return index
            }
        }
        return nil
    }
    
    func updateCellWithNameForUser(userId: String, watchCell: WatchVideoCollectionViewCell){
        self.userNamesRef.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userFB = snapshot.value as? [String:Any]{
                if let name = userFB["name"] as? String {
                    watchCell.setPieceUser(userName: name)
                }
                else {
                    
                }
            }
        })
        
    }
    
    func updateCellWithAdvert(watchCell: WatchVideoCollectionViewCell){
        
    }
    
    
    func updateCellWithTags(pieceID: Int, watchCell: WatchVideoCollectionViewCell) {
        self.transferDelegate.getPieceTopics(pieceId: pieceID, completion: watchCell.setPieceTopics);
    }
    
    
    
    // Setting up collection view
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(indexPath.section == 1) {
            let loadMoreCell = collectionView.dequeueReusableCell(withReuseIdentifier: "loadMoreCell", for: indexPath) as! LoadMoreCollectionViewCell;
            if(self.renderingItems.count > 4){
                loadMoreCell.textLabel.text = "Tap to load more";
            }
            return loadMoreCell;
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: feedCellIdentifier, for: indexPath) as! WatchVideoCollectionViewCell;
        
        
        if(indexPath.row == 3){
            var piec: PieceObj;
            if(advertisingItems.count > 0){
                piec = advertisingItems[0]
                cell.pieceTagsLabel.text = ""
            }
            else {
                print("No advertising items!");
                piec = renderingItems[indexPath.row];
            }
            
            cell.setPiece(piece: piec);
            cell.contentView.layer.backgroundColor = AD_BG.cgColor
            updateCellWithNameForUser(userId: piec.postedBy, watchCell: cell)
            updateCellWithTags(pieceID: piec.piece_id, watchCell: cell);
            
            
            
            //check to see if the cell has a downloaded video associated with it
            if self.fileNameToFilePathDict[piec.fileName] != nil {
                cell.addVideo(downloadFilePath: self.fileNameToFilePathDict[piec.fileName]!);
            }
            else {
                cell.showTemporaryVideo();
            }
            
            return cell;
            
        }
        
        let piec = renderingItems[indexPath.row]
        cell.setPiece(piece: piec);
        updateCellWithNameForUser(userId: piec.postedBy, watchCell: cell)
        updateCellWithTags(pieceID: piec.piece_id, watchCell: cell);
        
        
        
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
        
        if(section == 1){
            return 1;
        }
        if(renderingItems.count > loadCap){
            return loadCap;
        }
        else {
            return renderingItems.count;
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2;
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(indexPath.section == 1){
            return CGSize(width:self.view.frame.width, height:self.view.frame.height * 0.15);
        }
        
        return CGSize(width:self.view.frame.width, height:self.view.frame.height * 0.4);
    }
    
    //register taps for the song playing view
    func tappedSongView(sender: UITapGestureRecognizer){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller : SongDetailViewController = storyboard.instantiateViewController(withIdentifier: "SongDetailViewControllerInstance") as! SongDetailViewController
        controller.selectedPieceObj = self.renderingItems[currentPlayingMusicIndex];
        self.present(controller, animated: true, completion: nil)
    }
    
    
    func tappedAdvertView(sender: UITapGestureRecognizer){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller : AdvertDetailViewController = storyboard.instantiateViewController(withIdentifier: "AdvertViewControllerInstance") as! AdvertDetailViewController
        controller.selectedPieceObj = self.renderingItems[currentPlayingMusicIndex];
        self.present(controller, animated: true, completion: nil)
        
    }
    
    //register taps for the collectionview
    func tap(sender: UITapGestureRecognizer){
        
        self.stopPlayingSong();
        if(self.showingAdvertView == true){
            self.advertView.frame = CGRect.zero;
        }
        
        if let indexPath = self.feedCollectionView?.indexPathForItem(at: sender.location(in: self.feedCollectionView)) {
            
            if(indexPath.section == 1) {
                print("Load More cell pressed")
                let cell : LoadMoreCollectionViewCell = feedCollectionView.cellForItem(at: indexPath) as! LoadMoreCollectionViewCell;
                //loadmore
                self.loadMorePieces();
            }
            else {
                
                let cell : WatchVideoCollectionViewCell = feedCollectionView.cellForItem(at: indexPath) as! WatchVideoCollectionViewCell;
                
                
                
                self.playSpotifySong(uri: renderingItems[indexPath.row].spotifyTrackURI, atIndex:indexPath.row); //TODO - spotify vs apple music
                
                //TODO: fix the lag here
                let when = DispatchTime.now() + 1.3
                DispatchQueue.main.asyncAfter(deadline: when) {
                    cell.playVideo();
                }
                
                //this is an advert
                if(indexPath.row == 3){
                    print("tapped on row 3");
                    self.showAdvertView(width: self.view.frame.width, height: self.view.frame.height);
                    self.showingAdvertView = true;
                }
                
            }
            
            
            
            
        } else {
            print("feed view was tapped")
        }
    }
    
    
    func loadMorePieces(){
        self.loadCap += 5
        for i in 1...5 {
            if(self.piecesToDownload.count > 0){
                let p = self.piecesToDownload.removeFirst()
                self.appendToDownloadedPieces(pieceObj: p);
            }
        }
    }
    
    
    
    //interacting with collection view
    
    
    func toggleAutoPlay(){
        if self.autoplayOn == true {
            self.autoplayToggleButton.setTitle("autoplay off", for: [])
            self.autoplayOn = false
            //remove observer
        }
        else {
            //add observer / timer
            //var timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(FeedViewV1.updateFocusedPieceInCollection), userInfo: nil, repeats: true)
            self.autoplayToggleButton.setTitle("autoplay on", for: [])
            self.autoplayOn = true
        }
    }
    
    func updateFocusedPieceInCollection(){
        print("-- update called --");
        let cells = self.feedCollectionView.visibleCells;
        let centerY : CGFloat = (self.view.frame.size.height / 2.0)
        
        let sortedCells = cells.sorted { (first, second) -> Bool in
            abs(centerY - first.center.y) > abs(centerY - second.center.y) // sort by distance from center
            //feedCollectionView.indexPath(for: first)! > feedCollectionView.indexPath(for: second)! sort by index
        }
        
        let cell = cells.first;
        
        if cell != nil {
            let index : IndexPath = feedCollectionView.indexPath(for: cell!)!;
            
            print("current: \(currentFocusIndex) first: \(index.row)")
            
            if (currentFocusIndex == index.row) {
                //nothing to  do
            }
            else {
                let watchCell = cell as! WatchVideoCollectionViewCell
                currentFocusIndex = index.row;
                DispatchQueue.main.async {
                    watchCell.playVideo();
                }
            }
        }
        
        
    }
    
    
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    
    
    
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
    
    
    func showAdvertView(width: CGFloat, height: CGFloat){
        print("Adding advertView!!!")
        self.advertView.frame = CGRect(x: width * 0.63, y: height * 1.01, width: width * 0.35, height: height * 0.075);
        let bottomRightCornerFrame = CGRect(x: width * 0.63, y: height * 0.8, width: width * 0.35, height: height * 0.075);
        UIView.animate(withDuration: 0.5, animations: {
            self.advertView.frame = bottomRightCornerFrame;
        }, completion:{ (comp) in
            //add a little spinner or something
        });
        
    }
    
    func showPlayingSongView(width: CGFloat, height: CGFloat){
        self.playingMusicTitleView.frame = CGRect(x: width * 0.02, y: height * 1.01, width: width * 0.45, height: height * 0.12);
        let bottomLeftCornerFrame = CGRect(x: width * 0.02, y: height * 0.8, width: width * 0.45, height: height * 0.1);
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
    
    @IBAction func updatedSearchButtonPressed(_ sender: Any) {
        self.showSearchView(title: "search");
    }
    
    
    
    func showSearchView(title: String){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "UserSearchViewControllerInstance") as! UserSearchViewController
        //controller.titleText = title;
        //controller.browseTitleLabel.text = title
        //controller.hrefForPieces = some kind of search paramete/ url / quesry
        //todo controller.browseType = ENUM
        self.present(controller, animated: true, completion: nil)
    }
    
    func showUserProfileView(user: UserObject){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "UserProfileViewInstance") as! UserProfileViewController
        controller.user = user;
        self.present(controller, animated: true, completion: nil)
    }

    
    
    func searchPressed(){
        //go to search view
    }
    
    func composePressed(){
        //go to camera view
    }
    
    
    //End spotify section
}
