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
    //var feedCollectionView : UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false);
        // Do any additional setup after loading the view, typically from a nib.
        transferDelegate = TransferDelegate();
        transferDelegate.delegate = self
        transferDelegate.getAllPieces();
        
        //feedCollectionView = UICollectionView(frame: self.view.frame);
        //feedCollectionView.delegate = self
        //feedCollectionView.dataSource = self
        //self.view.addSubview(feedCollectionView);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func appendToDownloadedItems(filePath: String) {
        self.downloadItems.append(filePath);
        self.renderingItems.append(filePath);
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: feedCellIdentifier, for: indexPath) as! WatchVideoCollectionViewCell;
        cell.playVideo(downloadFilePath: renderingItems[indexPath.row]);
        return cell;
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("downlaoded count: \(renderingItems.count)");
        return renderingItems.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:self.view.frame.width, height:self.view.frame.height * 0.5);
    }
    
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
}
