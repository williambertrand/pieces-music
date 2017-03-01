//
//  TestWatchVideoViewController.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 11/13/16.
//  Copyright © 2016 Will Bert. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

import AWSCore
import AWSS3

class TestWatchVideoViewController: UIViewController {
    
    let S3BucketName = "pieces-bucket";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let fileName = "4A1F4758-A85F-4DE2-B5D9-BD49E687CA05-5635-0000069A14B8DFE2.mp4";
        let downloadFilePath = NSTemporaryDirectory().appending(fileName);
        //let downloadFilePath = NSTemporaryDirectory().stringByAppendingPathComponent(fileName)
        let downloadingFileURL = NSURL.fileURL(withPath: downloadFilePath)
        
        // Set the logging to verbose so we can see in the debug console what is happening
        AWSLogger.default()
        
        
        // Create a new download request to S3, and set its properties
        AWSServiceManager.default()
        
        let downloadRequest = AWSS3TransferManagerDownloadRequest()
        downloadRequest?.bucket = S3BucketName
        downloadRequest?.key  = fileName
        downloadRequest?.downloadingFileURL = downloadingFileURL
        
        let transferManager = AWSS3TransferManager.default()
        
        //block in .continue only run after task completes
        
        transferManager.download(downloadRequest!).continueWith(block: {
            (task: AWSTask!) -> AnyObject! in
            if task.error != nil {
                print("Error downloading")
                print(task.error?.localizedDescription)
            }
            else {
                // Set the UIImageView to show the file that was downloaded
                //self.watchVideoCollectionView.reloadData();
                print("---->>> downloaded something to \(downloadFilePath)");
                    let player = AVPlayer(url: NSURL(fileURLWithPath: downloadFilePath) as URL);
                    //let playerController = AVPlayerViewController()
                
                    //playerController.player = player
                    //self.addChildViewController(playerController)
                    //self.view.addSubview(player);
                    //playerController.view.frame = self.view.frame
                    let avPlayerLayer = AVPlayerLayer(player: player);
                    avPlayerLayer.frame = self.view.frame;
                    self.view.layer.insertSublayer(avPlayerLayer, at: 0);
                
                    player.play()
                    
                
                
                //let videoURL = NSURL(string: downloadFilePath)
            }
            
            return nil
        })
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
}
