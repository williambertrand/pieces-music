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



class PieceObj : NSObject {
    var title : String!
    var fileName : String!
    var s3Bucket : String!
    
    
    /* Takes dictionary with fields : title, file_name, bucket, as arguments */
    init(dict : NSDictionary) {
        self.title = dict["title"] as! String
        self.fileName = dict["file_name"] as! String
        self.s3Bucket = dict["bucket"] as! String
    }
}

protocol TransferDelegateViewController {
    func appendToDownloadedItems(filePath: String)
}


class TransferDelegate {
    
    var user_id : String! //TODO
    let piecesDBURL = "https://afternoon-cliffs-21515.herokuapp.com/pieces"
    
    
    let allPiecesUrl = "https://afternoon-cliffs-21515.herokuapp.com/pieces/sendtest"
    
    //TODO have one transfer delegate object for each bucket ideally or have it do uploads to multiple buckets?
    var transferBucketName : String!
    
    var delegate : TransferDelegateViewController!
    
    
    //TODO get a name for a piece file name
    func getPieceName(userID:String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let fileName = ProcessInfo.processInfo.globallyUniqueString
        let index = fileName.index(fileName.startIndex, offsetBy: 36);
        let retFileName = fileName.substring(from: index) + "-\(formatter.string(from: Date()))-\(userID).mp4"
        return retFileName;
    }
    
    func uploadToAws(videoPath: NSString, bucketName: String){
        self.transferBucketName = bucketName
        let fileName = getPieceName(userID: self.user_id);
        print("---------- now processing upload ----------")
        let fileURL = URL(fileURLWithPath: (videoPath as String));
        print(fileURL)
        //upload to the aws bucket
        let uploadRequest = AWSS3TransferManagerUploadRequest();
        uploadRequest?.body = fileURL;
        uploadRequest?.key = fileName;
        uploadRequest?.bucket = bucketName;
        self.upload(uploadRequest!);
        
        //add piece to the rails backend DB
        self.uploadPieceInfoItem(title: "title-TODO", description: "desc-TODO", song: "song-TODO", userID: self.user_id, fileName: fileName, bucketName: bucketName)
        
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
    
    /*
 
     Piece DB Fields:
     
     Title
     Description
     Song
     user
     file_name
     bucket
 
     */
    
    func uploadPieceInfoItem(title:String, description: String, song: String, userID:String, fileName:String, bucketName: String){
        
        let params = ["title":title, "description":description, "song":song, "user":userID, "file_name":fileName, "bucket":bucketName];
        let result = Alamofire.request(piecesDBURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["content-type":"application/json"])
        
        print(result)
    }
    
    func testUploadPiece(){
        uploadPieceInfoItem(title: "testFromNewApp", description: "this is from the new app", song: "Charlie XCX", userID: "testing", fileName: "testFile", bucketName: "pieces-staging-bucket22");
    }
    
    func getAllPieces() {
        Alamofire.request(allPiecesUrl)
            .responseJSON { response in
                // print response as string for debugging, testing, etc.
                if (response.result.error != nil){
                    
                }
                else {
                    if let result = response.result.value as! NSArray? {
                        for element in result {
                            let data = element as! NSDictionary
                            let obj = PieceObj(dict: data);
                            self.downloadPieceFromAwsBucket(piece: obj);
                            
                        }
                    }
                    else{
                        print("ERROR could not complete conversion from response to array")
                    }
                    
                }
                
                
        }
    
        
    }
    
    
    func downloadPieceFromAwsBucket(piece: PieceObj){
        let transferManager = AWSS3TransferManager.default()
        
        let fileName : String = piece.fileName!;
        let s3BucketName : String = piece.s3Bucket!;
        
        let downloadFilePath = NSTemporaryDirectory().appending(fileName);
        //get the url next
        let downloadingFileURL = NSURL.fileURL(withPath: downloadFilePath)
        
        //create the download request
        let downloadRequest = AWSS3TransferManagerDownloadRequest()
        downloadRequest?.bucket = s3BucketName
        downloadRequest?.key  = fileName
        downloadRequest?.downloadingFileURL = downloadingFileURL
        
        transferManager?.download(downloadRequest).continue ({
            (task: AWSTask!) -> AnyObject! in
            if task.error != nil {
                print("Error downloading \(task.debugDescription)")
                print(task.error?.localizedDescription);
            }
            else {
                //process finished download -> add feed item
                //append
                let s: String = (downloadRequest?.downloadingFileURL.path)!;
                self.delegate.appendToDownloadedItems(filePath: s);
            }
            
            return nil
        }) // end closure
        
    }
    
    
    func downloadPieceFilesFromAwsBucket(fileNames : [String], s3BucketName: String){
        //TODO make sure its ok to only use 1 instance of a transfermanager
        let transferManager = AWSS3TransferManager.default()
        for fileName in fileNames {
            //get path for the downloaded video file
            let downloadFilePath = NSTemporaryDirectory().appending(fileName);
            //get the url next
            let downloadingFileURL = NSURL.fileURL(withPath: downloadFilePath)
            
            //create the download request
            let downloadRequest = AWSS3TransferManagerDownloadRequest()
            downloadRequest?.bucket = s3BucketName
            downloadRequest?.key  = fileName
            downloadRequest?.downloadingFileURL = downloadingFileURL
            
            transferManager?.download(downloadRequest).continue ({
                (task: AWSTask!) -> AnyObject! in
                if task.error != nil {
                    print("Error downloading \(task.debugDescription)")
                    print(task.error?.localizedDescription)
                }
                else {
                    //process finished download -> add feed item
                    //append
                    self.delegate.appendToDownloadedItems(filePath: "\(downloadRequest?.downloadingFileURL)");
                }
                
                return nil
            }) // end closure
            
        }
    }
    
    
    

    
    
}
