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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false);
        // Do any additional setup after loading the view, typically from a nib.
        transferDelegate = TransferDelegate();
        transferDelegate.delegate = self
        transferDelegate.getAllPieces();
        
        let feedFrame = CGRect(x: 0, y: self.view.frame.height * 0.1, width: self.view.frame.width, height: self.view.frame.height * 0.9);
        let feedLayout = UICollectionViewFlowLayout()
        feedLayout.itemSize = CGSize(width: self.view.frame.width, height: self.view.frame.height * 0.55);
        
        feedCollectionView = UICollectionView(frame: feedFrame, collectionViewLayout: feedLayout);
        feedCollectionView.backgroundColor = UIColor.white;
        feedCollectionView.register(WatchVideoCollectionViewCell.self, forCellWithReuseIdentifier: feedCellIdentifier);
        
        feedCollectionView.delegate = self
        feedCollectionView.dataSource = self
        
        self.view.addSubview(feedCollectionView);
        self.feedCollectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func appendToDownloadedItems(filePath: String) {
        self.downloadItems.append(filePath);
        self.renderingItems.append(filePath);
        print("FEED VIEW APPENDING: " + filePath);
        self.feedCollectionView.reloadData();
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
        print("redning count: \(self.renderingItems.count)");
        return renderingItems.count;
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:self.view.frame.width, height:self.view.frame.height * 0.4);
    }
    
    
    //interacting with collection view
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell : WatchVideoCollectionViewCell = collectionView.cellForItem(at: indexPath) as! WatchVideoCollectionViewCell;
        cell.playVideo();
        
    }
    
    
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
}
