//
//  TransferDelegate.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 2/2/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import Foundation
import AWSCore
import AWSS3
import Alamofire


class TransferDelegate {
    
    //TODO have one transfer delegate object for each bucket ideally or have it do uploads to multiple buckets?
    var transferBucketName : String!
    
    
    func testUploadPiece(){
        //todo: add alamofire
    }
    
    
    func uploadToAws(videoPath: NSString, bucketName: String){
        self.transferBucketName = bucketName
        let fileName = ProcessInfo.processInfo.globallyUniqueString + ".mp4" //TODO
        print("---------- now processing upload ----------")
        let fileURL = URL(fileURLWithPath: (videoPath as String));
        print(fileURL)
        //upload to the aws bucket
        let uploadRequest = AWSS3TransferManagerUploadRequest();
        uploadRequest?.body = fileURL;
        uploadRequest?.key = fileName;
        uploadRequest?.bucket = bucketName;
        self.upload(uploadRequest!);
        
        
        
    }
    
    func upload(_ uploadRequest: AWSS3TransferManagerUploadRequest) {
        print("in upload request");
        let transferManager = AWSS3TransferManager.default()
        
        transferManager?.upload(uploadRequest).continue( { (task) -> AnyObject! in
            if let error = task.error {
                if error._domain == AWSS3TransferManagerErrorDomain as String {
                    if let errorCode = AWSS3TransferManagerErrorType(rawValue: error._code) {
                        switch (errorCode) {
                        case .cancelled, .paused:
                            DispatchQueue.main.async(execute: { () -> Void in
                                
                            })
                            break;
                            
                        default:
                            print("upload() failed: [\(error)]")
                            break;
                        }
                    } else {
                        print("upload() failed: [\(error)]")
                    }
                } else {
                    print("upload() failed: [\(error)]")
                }
            }
            
            if let exception = task.exception {
                print("upload() failed: [\(exception)]")
            }
            
            if task.result != nil {
                DispatchQueue.main.async(execute: { () -> Void in
                    print("upload completed to AWS");
                })
            }
            return nil
        })
    }

    
    
}
