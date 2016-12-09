//
//  WatchVideoViewController.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 11/13/16.
//  Copyright © 2016 Ray Wenderlich. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit
import AWSS3
import AWSCore

class WatchVideoViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let watchCell = "watchCell";
    let s3BucketName = "pieces-bucket";
    
    
    let testFileNames = ["4A1F4758-A85F-4DE2-B5D9-BD49E687CA05-5635-0000069A14B8DFE2.mp4", "147C341D-0849-43D2-B96B-D4FAA2C197F2-5665-000006A9091D546B.mp4", "9BFC000D-DAB4-4075-BEE9-B19B13342045-5665-000006A920A6633D.mp4"];
    
    @IBOutlet var watchVideoCollectionView: UICollectionView!
    
    var downloadRequests = Array<AWSS3TransferManagerDownloadRequest?>()
    var downloadFileURLs = Array<URL?>()
    var itemsDownloaded = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //init collection view
        watchVideoCollectionView.register(WatchVideoCollectionViewCell.self, forCellWithReuseIdentifier: watchCell)
        watchVideoCollectionView.delegate = self;
        watchVideoCollectionView.dataSource = self;
        
        listObjects()
        //listBucketObjects()
        
        do {
            try FileManager.default.createDirectory(
                at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("download"),
                withIntermediateDirectories: true,
                attributes: nil)
        } catch {
            print("Creating 'download' directory failed. Error: \(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func listBucketObjects(){
        print("listing:");
        
        let s3 = AWSS3.s3(forKey: "USWest2S3");
        //let s3 = AWSS3.default();
        let listObjectsRequest = AWSS3ListObjectsRequest()
        listObjectsRequest?.bucket = S3BucketName
        
        s3.listObjects(listObjectsRequest!).continue({ (task) -> AnyObject! in
            
            if let error = task.error {
                print("listObjects failed with error: [\(error)]")
            }
            
            if let listObjectsOutput = task.result as AWSS3ListObjectsOutput? {
                print("********* MADE IT INTO TASK *********");
                if let contents = listObjectsOutput.contents {
                    for s3Object in contents {
                        print("KEY: \(s3Object.key!)");
                    }
                }
            }
            return nil;
        });
        
    }
    
    func listObjects() {
        print("listing:");
        
        let s3 = AWSS3.s3(forKey: "USWest2S3");
        //let s3 = AWSS3.default();
        let listObjectsRequest = AWSS3ListObjectsRequest()
        listObjectsRequest?.bucket = S3BucketName
        
        s3.listObjects(listObjectsRequest!).continue({ (task) -> AnyObject! in
            
            if let error = task.error {
                print("listObjects failed with error: [\(error)]")
            }
            if let exception = task.exception {
                print("listObjects failed with exception: [\(exception)]")
            }
            if let listObjectsOutput = task.result as AWSS3ListObjectsOutput? {
                print("********* MADE IT INTO TASK *********");
                if let contents = listObjectsOutput.contents {
                    for s3Object in contents {
                        //let downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("download").appendingPathComponent(s3Object.key!)
                        //let downloadingFilePath = downloadingFileURL.path
                        
                        let fileName = s3Object.key!;
                        let downloadFilePath = NSTemporaryDirectory().appending(s3Object.key!);
                        //let downloadFilePath = NSTemporaryDirectory().stringByAppendingPathComponent(fileName)
                        let downloadingFileURL = NSURL.fileURL(withPath: downloadFilePath)
                        
                        // Set the logging to verbose so we can see in the debug console what is happening
                        AWSLogger.default()
                        
                        
                        // Create a new download request to S3, and set its properties
                        AWSServiceManager.default()
                        
                        let downloadRequest = AWSS3TransferManagerDownloadRequest()
                        downloadRequest?.bucket = self.s3BucketName
                        downloadRequest?.key  = fileName
                        downloadRequest?.downloadingFileURL = downloadingFileURL
                        
                        let transferManager = AWSS3TransferManager.default()
                        transferManager?.download(downloadRequest).continue ({
                            (task: AWSTask!) -> AnyObject! in
                            if task.error != nil {
                                print("Error downloading")
                                print(task.error?.localizedDescription)
                            }
                            else {
                                // Set the UIImageView to show the file that was downloaded
                                self.itemsDownloaded.append(downloadFilePath);
                                self.watchVideoCollectionView.reloadData();
                                print("---->>> downloaded something to \(downloadFilePath)");
                                //let videoURL = NSURL(string: downloadFilePath)
                            }
                            
                            return nil
                        });
                }
            }
        }
            
            return nil;
            
        });
        
    }
    
    func ListTestObjects(){
        for fileName in testFileNames {
            let downloadFilePath = NSTemporaryDirectory().appending(fileName);
            //let downloadFilePath = NSTemporaryDirectory().stringByAppendingPathComponent(fileName)
            let downloadingFileURL = NSURL.fileURL(withPath: downloadFilePath)
            
            // Set the logging to verbose so we can see in the debug console what is happening
            AWSLogger.default()
            
            
            // Create a new download request to S3, and set its properties
            AWSServiceManager.default()
            
            let downloadRequest = AWSS3TransferManagerDownloadRequest()
            downloadRequest?.bucket = s3BucketName
            downloadRequest?.key  = fileName
            downloadRequest?.downloadingFileURL = downloadingFileURL
            
            let transferManager = AWSS3TransferManager.default()
            transferManager?.download(downloadRequest).continue ({
                (task: AWSTask!) -> AnyObject! in
                if task.error != nil {
                    print("Error downloading")
                    print(task.error?.localizedDescription)
                }
                else {
                    // Set the UIImageView to show the file that was downloaded
                    self.itemsDownloaded.append(downloadFilePath);
                    self.watchVideoCollectionView.reloadData();
                    print("---->>> downloaded something to \(downloadFilePath)");
                    //let videoURL = NSURL(string: downloadFilePath)
                }
                
                return nil
            })
        }
    }

    func download(_ downloadRequest: AWSS3TransferManagerDownloadRequest) {
        switch (downloadRequest.state) {
        case .notStarted, .paused:
            let transferManager = AWSS3TransferManager.default()
            transferManager?.download(downloadRequest).continue({ (task) -> AnyObject! in
                if let error = task.error {
                    if error._domain == AWSS3TransferManagerErrorDomain as String
                        && AWSS3TransferManagerErrorType(rawValue: error._code) == AWSS3TransferManagerErrorType.paused {
                        print("Download paused.")
                    } else {
                        print("download failed: [\(error)]")
                    }
                } else if let exception = task.exception {
                    print("download failed: [\(exception)]")
                } else {
                    DispatchQueue.main.async(execute: { () -> Void in
                        if let index = self.indexOfDownloadRequest(self.downloadRequests, downloadRequest: downloadRequest) {
                            self.downloadRequests[index] = nil
                            self.downloadFileURLs[index] = downloadRequest.downloadingFileURL
                            
                            let indexPath = IndexPath(row: index, section: 0)
                            self.watchVideoCollectionView.reloadItems(at: [indexPath])
                        }
                    })
                }
                return nil
            })
            
            break
        default:
            break
        }
    }
    
    func downloadAll() {
        for (_, value) in self.downloadRequests.enumerated() {
            if let downloadRequest = value {
                if downloadRequest.state == .notStarted
                    || downloadRequest.state == .paused {
                     self.download(downloadRequest)
                }
            }
        }
        
        self.watchVideoCollectionView.reloadData()
    }
    
    
    //collection view stuff
    func indexOfDownloadRequest(_ array: Array<AWSS3TransferManagerDownloadRequest?>, downloadRequest: AWSS3TransferManagerDownloadRequest?) -> Int? {
        for (index, object) in array.enumerated() {
            if object == downloadRequest {
                return index
            }
        }
        return nil
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: watchCell, for: indexPath) as! WatchVideoCollectionViewCell;
        cell.playVideo(downloadFilePath: itemsDownloaded[indexPath.row]);
        return cell;
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("downlaoded count: \(downloadFileURLs.count)");
        return itemsDownloaded.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:self.view.frame.width, height:self.view.frame.height * 0.5);
    }
    
    
    
    
    
    
}
