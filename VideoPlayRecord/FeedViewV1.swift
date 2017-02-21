//
//  FeedViewV1.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 2/9/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import Foundation
import UIKit
import AWSCore
import AWSS3

class FeedViewV1 : UIViewController, TransferDelegateViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //all vde
    var downloadItems = [String]()
    var renderingItems = [String]()
    
    var transferDelegate : TransferDelegate!
    
    let feedCellIdentifier = "FEED_CELL"
    var feedCollectionView : UICollectionView!
    
    var currentFocusIndex : Int = -1 // track which view is currently focused
    
    var autoplayToggleButton : UIButton!;
    var autoplayOn : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false);
        // Do any additional setup after loading the view, typically from a nib.
        transferDelegate = TransferDelegate();
        transferDelegate.delegate = self
        
        //TODO - display temp loading pieces
        
        transferDelegate.getAllPieces();
        let height = self.view.frame.height;
        let width = self.view.frame.width;
        
        let apFrame = CGRect(x: 0, y: height * 0.9, width: width * 0.2, height: height * 0.1);
        autoplayToggleButton = UIButton(frame: apFrame);
        autoplayToggleButton.setTitle("autoplay off", for: []);
        autoplayToggleButton.contentMode = .center;
        autoplayToggleButton.titleLabel?.font = UIFont(name: "Helvetica Nue", size: 14);
        autoplayToggleButton.titleLabel?.textColor = UIColor.darkGray;
        autoplayToggleButton.addTarget(self, action: #selector(FeedViewV1.toggleAutoPlay), for: .touchUpInside);
        
        
        let feedFrame = CGRect(x: 0, y: self.view.frame.height * 0.1, width: self.view.frame.width, height: self.view.frame.height * 0.9);
        let feedLayout = UICollectionViewFlowLayout()
        feedLayout.itemSize = CGSize(width: self.view.frame.width, height: self.view.frame.height * 0.55);
        
        feedCollectionView = UICollectionView(frame: feedFrame, collectionViewLayout: feedLayout);
        feedCollectionView.backgroundColor = UIColor.white;
        feedCollectionView.register(WatchVideoCollectionViewCell.self, forCellWithReuseIdentifier: feedCellIdentifier);
        
        feedCollectionView.delegate = self
        feedCollectionView.dataSource = self
        
        self.view.addSubview(feedCollectionView);
        
        feedCollectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func appendToDownloadedItems(filePath: String) {
        self.downloadItems.append(filePath);
        self.renderingItems.append(filePath);
        //self.feedCollectionView.reloadData();
        
        if self.renderingItems.count > 2 {
            DispatchQueue.main.async {
                self.feedCollectionView.reloadData()
            }
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
    
    // Setting up collection view
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: feedCellIdentifier, for: indexPath) as! WatchVideoCollectionViewCell;
        cell.displayVideo(downloadFilePath: renderingItems[indexPath.row]);
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
    
    //register taps for the collectionview
    func tap(sender: UITapGestureRecognizer){
        
        if let indexPath = self.feedCollectionView?.indexPathForItem(at: sender.location(in: self.feedCollectionView)) {
            let cell : WatchVideoCollectionViewCell = feedCollectionView.cellForItem(at: indexPath) as! WatchVideoCollectionViewCell;
            print(cell.isPlaying);
            cell.playVideo();
            
            
        } else {
            print("feed view was tapped")
        }
    }
    
    
    //interacting with collection view
    
//    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
//        print("HIGHLIGHTED: \(indexPath.row)")
//        let cell : WatchVideoCollectionViewCell = collectionView.cellForItem(at: indexPath) as! WatchVideoCollectionViewCell;
//        cell.playVideo();
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("HIGHLIGHTED: \(indexPath.row)")
//        let cell : WatchVideoCollectionViewCell = collectionView.cellForItem(at: indexPath) as! WatchVideoCollectionViewCell;
//        cell.playVideo();
//    }
    
    
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
}
