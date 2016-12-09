//
//  TestDownloadViewController.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 11/13/16.
//  Copyright © 2016 Ray Wenderlich. All rights reserved.
//

import Foundation
import UIKit
import AWSS3
import AWSCore

class TestDownloadViewController : UIViewController {
    
    @IBOutlet var testImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hard-coded names for the tutorial bucket and the file uploaded at the beginning
        let s3BucketName = "pieces-bucket"
        let fileName = "test.jpg"
        
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
                let image = UIImage(contentsOfFile: downloadFilePath)
                print("LOOK: \(downloadFilePath)");
                self.testImageView.image = image
            }
            
            return nil
        }) // end closure
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


