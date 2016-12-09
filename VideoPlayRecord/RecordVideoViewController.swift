//
//  RecordVideoViewController.swift
//  Pieces
//
//  Created by William Bertrand on 11/1/16.
//  Copyright © 2016 Bert. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import AssetsLibrary
import AWSS3


class RecordVideoViewController: UIViewController {
    
    //AWS S3 upload request:
    var uploadRequests = Array<AWSS3TransferManagerUploadRequest?>()
    var uploadFileUrls = Array<URL?>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }
    @IBAction func record(_ sender: Any) {
        self.startCameraFromViewController(viewController: self, withDelegate: self);
    }
    
    @IBAction func startPressed(_ sender: Any) {
        self.startCameraFromViewController(viewController: self, withDelegate: self);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func startCameraFromViewController(viewController: UIViewController, withDelegate delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) -> Bool {
        
        print("starting camera!!!");
        
        //check if camera is available
        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            return false
        }
        
        let cameraController = UIImagePickerController()
        cameraController.sourceType = .camera
        cameraController.mediaTypes = [kUTTypeMovie as String]
        //cameraController.mediaTypes = [kUTTypeMovie as NSString as String]
        cameraController.allowsEditing = false
        cameraController.delegate = self
        
        present(cameraController, animated: true, completion: {print("completed present")});
        return true
    }
    
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        print("updating focus!!!");
    }
    
    func video(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        print("finished saving file to phone")
        let fileName = ProcessInfo.processInfo.globallyUniqueString + ".mp4" //TODO
        print("---------- now processing upload ----------")
        let fileURL = URL(fileURLWithPath: (videoPath as String));
        print(fileURL)
        //upload to the aws bucket
        let uploadRequest = AWSS3TransferManagerUploadRequest();
        uploadRequest?.body = fileURL;
        uploadRequest?.key = fileName;
        uploadRequest?.bucket = S3BucketName
        self.upload(uploadRequest!);
        
        var title = "Success"
        var message = "Video was saved"
        if let _ = error {
            title = "Error"
            message = "Video failed to save"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
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
//                    if let index = self.indexOfUploadRequest(self.uploadRequests, uploadRequest: uploadRequest) {
//                        self.uploadRequests[index] = nil
//                        self.uploadFileURLs[index] = uploadRequest.body
//
//                        let indexPath = IndexPath(row: index, section: 0)
//                        self.collectionView.reloadItems(at: [indexPath])
//                    }
                    
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200));
                    label.textAlignment = .center;
                    label.text = "Upload completed";
                    label.textColor = UIColor.blue
                    label.font = UIFont.boldSystemFont(ofSize: 40);
                    self.view.addSubview(label);
                    print("added label");
                })
            }
            return nil
        })
    }
    
    
}


extension RecordVideoViewController : UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("in method");
        print(info);
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        dismiss(animated: true, completion: nil)
        // Handle a movie capture
        if mediaType == kUTTypeMovie {
            print("movie");
            
            guard let path = (info[UIImagePickerControllerMediaURL] as! NSURL).path else { return }
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) {
                
                UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(RecordVideoViewController.video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
                
            }
            else{
                print("no path");
            }
        }
    }
}


extension RecordVideoViewController: UINavigationControllerDelegate {
    
}
