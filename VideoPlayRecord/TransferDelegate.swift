//
//  TransferDelegate.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 2/2/17.
//  Copyright © 2017 Will Bert. All rights reserved.
//

import Foundation
import AWSCore
import AWSS3
import Alamofire


protocol TransferDelegateViewController {
    func appendToDownloadedItems(filePath: String);
    func appendToDownloadedPieces(fileName: String, filePath: String);
    func appendToDownloadedPieces(pieceObj: PieceObj);
    func appendToAdvertisingPieces(pieceObj: PieceObj)
    func appendToDownloadedAdvertisingPieces(fileName: String, filePath: String);
}


class TransferDelegate {
    
    var user_id : String! //TODO
    let piecesDBURL = "https://afternoon-cliffs-21515.herokuapp.com/piece_items"
    
    
    let allPiecesUrl = "https://afternoon-cliffs-21515.herokuapp.com/piece_items/sendall"
    let followingFriendsURL = "https://afternoon-cliffs-21515.herokuapp.com/users/following"
    let followersURL = "https://afternoon-cliffs-21515.herokuapp.com/users/followers"
    
    let myPiecesURL = "https://afternoon-cliffs-21515.herokuapp.com/piece_items/user"
    
    
    let pieceTopicsURL = "https://peaceful-dawn-25448.herokuapp.com/pieces/piece-topic"
    
    let exampleAdKey = "example-advertisement.mp4";
    
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
    
    func uploadToAws(videoPath: NSString, bucketName: String, fileName: String){
        self.transferBucketName = bucketName
        print("---------- now processing upload ----------")
        let fileURL = URL(fileURLWithPath: (videoPath as String));
        
        //upload to the aws bucket
        let uploadRequest = AWSS3TransferManagerUploadRequest();
        uploadRequest?.body = fileURL;
        uploadRequest?.key = fileName;
        uploadRequest?.bucket = bucketName;
        
        
        self.upload(uploadRequest!);
    }
    
    func uploadPieceObject(pieceObj: PieceObj){
        self.uploadPieceInfoItem(title:"Piece", description: "This is a Piece", song: pieceObj.title, songId: pieceObj.spotifyTrackID, spotifyTrackUri: pieceObj.spotifyTrackURI, userID:Current_User.uid, fileName:pieceObj.fileName, bucketName: pieceObj.s3Bucket)
    }
    
    
    func uploadPieceObject(fileName: String, bucketName: String){
        //add piece to the rails backend DB
    }
    
    func upload(_ uploadRequest: AWSS3TransferManagerUploadRequest) {
        print("in upload request");
        let transferManager = AWSS3TransferManager.default();
        
        transferManager.upload(uploadRequest).continueWith(block: { (task) -> AnyObject! in
            if let error = task.error {
                print(error);
                
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
            
            if let exception = task.error {
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
    
    func uploadPieceInfoItem(title:String, description: String, song: String, songId: String, spotifyTrackUri: String, userID:String, fileName:String, bucketName: String){
        
        print("In upload piuece info item function:");
        
        print("id: \(songId), uri: \(spotifyTrackUri)");
        
        print("#####################################");
        
        let params = ["title":"Piece", "song_title":song, "spt_track_id":songId, "spt_track_uri":spotifyTrackUri, "apple_track_id":"id", "apple_track_uri":"apple_uri", "description": "description here", "posted_by": userID, "s3_file_name": fileName, "file_name": fileName, "bucket_name":bucketName];
        
        let result = Alamofire.request(piecesDBURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["content-type":"application/json"])
        
        print(result)
    }
    
    
    func getFollowers(userId: String){
        let params = ["id":userId];
        let result = Alamofire.request(piecesDBURL, method: .get, parameters: params, encoding: JSONEncoding.default, headers: ["content-type":"application/json"]).responseJSON { response in
            
            if(response.result.error != nil){
                //Error getting followers
                print("Error Getting followers: " + response.result.error.debugDescription);
            }
            else {
                //Got followers
                if let result = response.result.value as! NSArray? {
                    for element in result {
                        let data = element as! NSDictionary
                        //let obj = UserObj(dict: data);
                        //self.delegate.appendtoUserResults(obj)
                    }
                }
            }
            
        }
    }
    
    func testUploadPiece(){
        //uploadPieceInfoItem(title: "testFromNewApp", description: "this is from the new app", song: "Charlie XCX", userID: "testing", fileName: "testFile", bucketName: "pieces-staging-bucket22");
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
                            //check for advert type
                            self.delegate.appendToDownloadedPieces(pieceObj: obj);
                            //self.downloadPieceFromAwsBucket(piece: obj);
                            
                        }
                    }
                    else{
                        print("ERROR could not complete conversion from response to array")
                    }
                    
                }
                
                
        }
    
        
    }
    
    func getPiecesForUser(userId: String, limit: Int){
        let userPiecesUrl = "https://afternoon-cliffs-21515.herokuapp.com/piece_items/byuser?id=\(userId)"
        Alamofire.request(userPiecesUrl)
            .responseJSON { response in
                // print response as string for debugging, testing, etc.
                if (response.result.error != nil){
                    
                }
                else {
                    if let result = response.result.value as! NSArray? {
                        for element in result {
                            let data = element as! NSDictionary
                            let obj = PieceObj(dict: data);
                            //check for advert type
                            self.delegate.appendToDownloadedPieces(pieceObj: obj);
                            //self.downloadPieceFromAwsBucket(piece: obj);
                            
                        }
                    }
                    else{
                        print("ERROR could not complete conversion from response to array")
                    }
                    
                }
                
                
        }
        
    }
    
    func getPieceForTestAdvert() -> PieceObj {
        let adPiece = PieceObj(user: "Promoted");
        adPiece.title = "Promoted"
        adPiece.fileName = exampleAdKey
        adPiece.s3Bucket = "pieces-development-bucket";
        adPiece.piece_id = 20;
        adPiece.spotifyTrackID = "177fO1uA7UEUR49Ra4FpXR";
        adPiece.spotifyTrackURI = "spotify:track:177fO1uA7UEUR49Ra4FpXR";
        adPiece.songTitle = "Montage (feat. Paul Dano and Daniel Radcliffe)"
        return adPiece;
    }
    
    var currentDownload = 1
    
    func downloadPieceFromAwsBucket(piece: PieceObj){
        let transferManager = AWSS3TransferManager.default()
        
        let fileName : String = piece.fileName!;
        let s3BucketName : String = piece.s3Bucket!;
        print("s3 bucket: \(s3BucketName)");
        
        let downloadFilePath = NSTemporaryDirectory().appending(fileName);
        //get the url next
        let downloadingFileURL = NSURL.fileURL(withPath: downloadFilePath);
        
        //create the download request
        let downloadRequest = AWSS3TransferManagerDownloadRequest()
        downloadRequest?.bucket = s3BucketName
        downloadRequest?.key  = fileName
        downloadRequest?.downloadingFileURL = downloadingFileURL
        
        transferManager.download(downloadRequest!).continueWith(block: {
            (task: AWSTask!) -> AnyObject! in
            if task.error != nil {
                print("Error downloading \(task.debugDescription)")
                print(task.error?.localizedDescription);
            }
            else {
                //process finished download -> add feed item
                //append
                let s: String = (downloadRequest?.downloadingFileURL.path)!
                self.delegate.appendToDownloadedPieces(fileName: (downloadRequest?.key)!, filePath: s);
            }
            
            return nil
        }) // end closure
        
    }
    
    func downloadAdvertisingPieceFromAwsBucket(piece: PieceObj){
        let transferManager = AWSS3TransferManager.default()
        
        let fileName : String = piece.fileName!;
        let s3BucketName : String = piece.s3Bucket!;
        print("s3 bucket: \(s3BucketName)");
        
        let downloadFilePath = NSTemporaryDirectory().appending(fileName);
        //get the url next
        let downloadingFileURL = NSURL.fileURL(withPath: downloadFilePath);
        
        //create the download request
        let downloadRequest = AWSS3TransferManagerDownloadRequest()
        downloadRequest?.bucket = s3BucketName
        downloadRequest?.key  = fileName
        downloadRequest?.downloadingFileURL = downloadingFileURL
        
        transferManager.download(downloadRequest!).continueWith(block: {
            (task: AWSTask!) -> AnyObject! in
            if task.error != nil {
                print("Error downloading \(task.debugDescription)")
                print(task.error?.localizedDescription);
            }
            else {
                //process finished download -> add feed item
                //append
                print("Downloaded \(self.currentDownload) !!!!!!!!!")
                let s: String = (downloadRequest?.downloadingFileURL.path)!
                self.delegate.appendToDownloadedAdvertisingPieces(fileName: (downloadRequest?.key)!, filePath: s);
            }
            
            return nil
        }) // end closure
        
    }
    
    
    
    
    func downloadPieceAdvertFilesFromAwsBucket(fileNames : [String], s3BucketName: String){
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
            
            transferManager.download(downloadRequest!).continueWith(block: {
                (task: AWSTask!) -> AnyObject! in
                if task.error != nil {
                    print("Error downloading \(task.debugDescription)")
                    print(task.error?.localizedDescription)
                }
                else {
                    //process finished download -> add feed item
                    //append
                    //self.delegate.appendToAdvertisingItems(filePath: "\(downloadRequest?.downloadingFileURL)");
                }
                
                return nil
            }) // end closure
            
        }
    }
    
    
    func getPieceTopics(pieceId: Int, completion:@escaping (_ topicList: [String]) -> Void){
        let topicUrlReq = pieceTopicsURL + "?pieceId=\(pieceId)"
        Alamofire.request(topicUrlReq).responseJSON { (response) in
            if let result = response.result.value as! NSArray? {
                if result.count == 0{
                    completion(["No Tags"]);
                    return;
                }
                else {
                    if let topicObj = result[0] as? NSDictionary{
                        if let topics = topicObj["topics"] as? [String] {
                            completion(topics);
                        }
                        else{
                            completion(["No Tags"])
                        }
                    }
                    else{
                        completion(["No Tags"])
                    }

                    
                }
                
            }
        }
        
        
    }
    
    
    

    
    
}
;
