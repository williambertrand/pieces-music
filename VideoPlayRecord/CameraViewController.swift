//
//  CameraViewController.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 2/2/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AssetsLibrary

class CameraViewController : UIViewController, AVCaptureFileOutputRecordingDelegate, TransferDelegateViewController {
    
    var captureSession : AVCaptureSession? = nil
    var captureDevice : AVCaptureDevice? = nil
    var captureMovieFileOutput : AVCaptureMovieFileOutput? = nil
    var captureVideoPreviewLayer : AVCaptureVideoPreviewLayer? = nil
    
    var is_recording : Bool = false
    
    
    var record_button : UIButton!
    
    var record_label : UILabel!
    
    var fileUrl : URL? = nil
    var finalVideoURL : URL? = nil
    
    
    @IBOutlet var recordLabel: UILabel!
    
    @IBOutlet var cameraView: UIView!
    
    var transferDelegate : TransferDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        transferDelegate = TransferDelegate()
        transferDelegate.delegate = self
        transferDelegate.user_id = "testUser1000";
        // Do any additional setup after loading the view.
        //self.addRecordButton(width: self.view.frame.width, height: self.view.frame.height);
        self.setupCapture()
    }
    
    func addRecordButton(width: CGFloat, height: CGFloat){
        let recButtonFrame = CGRect(x: width * 0.45, y: height * 0.8, width: width * 0.1, height: height * 0.15);
        record_button = UIButton(frame: recButtonFrame);
        record_button.setImage(UIImage(named:"recordIcon"), for: [])
        record_button.imageView?.contentMode = .scaleAspectFit
        self.view.addSubview(record_button);
    }
    
    func addRecordLabel(width: CGFloat, height: CGFloat){
        let recLabelFrame = CGRect(x: width * 0.1, y: height * 0.85, width: width * 0.8, height: height * 0.15);
        record_label = UILabel(frame: recLabelFrame);
        record_label.text = "Tap To Record"
        record_label.textColor = UIColor.white
        record_label.font = UIFont(name: "Avenir", size: 20);
        record_label.contentMode = .center
        self.view.addSubview(record_label);
        
        
    }
    
    func setupCapture(){
        self.captureSession = AVCaptureSession()
        self.captureDevice = self.getVideoDeviceWithPosition(.back);
        var videoInput : AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: self.captureDevice);
        }
        catch {
            print("Failed trying to add video input to device")
            return
        }
        
        if(self.captureSession?.canAddInput(videoInput))!{
            self.captureSession?.addInput(videoInput);
        }
        else {
            print("Failed trying to add video input to session")
        }

        // if (self.captureSession?.canAddInput(audioInput))! {
        //    self.captureSession?.addInput(audioInput)
        // }
        
        self.captureMovieFileOutput = AVCaptureMovieFileOutput()
        if(self.captureSession?.canAddOutput(self.captureMovieFileOutput))!{
            self.captureSession?.addOutput(self.captureMovieFileOutput);
        }
        
        self.captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.captureVideoPreviewLayer?.frame = cameraView.frame
        self.captureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        cameraView.layer.addSublayer(self.captureVideoPreviewLayer!)
        
        self.addRecordLabel(width: self.view.frame.width, height: self.view.frame.height)
        self.captureSession?.startRunning()
        
        
    }
    
    
    //compress the video to a differnet quality and export it using an exportSession
    func compressRecordedVideo(url: URL){
        let start = NSDate()
        let avAsset = AVURLAsset(url: url)
        let presetsCompatible = AVAssetExportSession.exportPresets(compatibleWith: avAsset)
        let pieceBucket = "pieces-staging-bucket";
        
        if (presetsCompatible.contains(AVAssetExportPresetMediumQuality)) {
            let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetMediumQuality)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
            let filename = "piece-video-\(formatter.string(from: Date())).mp4"
            let outputFielPath = NSTemporaryDirectory().appending(filename)
            let saveUrl = NSURL.fileURL(withPath: outputFielPath)
            self.finalVideoURL = saveUrl
            exportSession?.outputURL = saveUrl
            exportSession?.shouldOptimizeForNetworkUse = true
            exportSession?.outputFileType = AVFileTypeMPEG4
            exportSession?.exportAsynchronously( completionHandler: {
                if exportSession?.status == AVAssetExportSessionStatus.completed {
                    let time = -start.timeIntervalSinceNow;
                    print("Compression Time: \(time)")
                    print("original File Size: \(self.getFileSize(path: url.path))")
                    print("compresed File Size: \(self.getFileSize(path: saveUrl.path))")
                    self.transferDelegate.uploadToAws(videoPath: saveUrl.path as NSString, bucketName: pieceBucket);
                }
                
            }); //end of completion handler for export session
            
        }
        
    }
    
    
    func getVideoDeviceWithPosition(_ position:AVCaptureDevicePosition) -> AVCaptureDevice! {
        
        let devices : [AVCaptureDevice] = AVCaptureDevice.devices() as! [AVCaptureDevice]
        for device in devices {
            if device.hasMediaType(AVMediaTypeVideo){
                if device.position == position {
                    self.captureDevice = device;
                    return device
                }
                
            }
        }
        print("returning default device")
        return AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    }
    
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        self.compressRecordedVideo(url: outputFileURL);
    }
    
    //TODO: move to utils file
    func getFileSize(path:String) -> Int{
        var fileSize = 0
        do {
            let outputFileAttributes = try FileManager().attributesOfItem(atPath: path) as NSDictionary?
            if let attr = outputFileAttributes {
                fileSize = Int(attr.fileSize())
            }
        } catch {
            print("_getFileSize \(error)")
        }
        return fileSize
    }
    
    func appendToDownloadedItems(filePath: String) {
        //Implement when needed
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("tapped")
        self.toggleRecord();
        //TODO self.startRecordAnimation();
    }
    
    
    func toggleRecord() {
        if is_recording == false {
            let captureConnection = self.captureMovieFileOutput?.connection(withMediaType: AVMediaTypeVideo)
            captureConnection?.videoOrientation = (self.captureVideoPreviewLayer?.connection.videoOrientation)!
            let outputFielPath = NSTemporaryDirectory().appending("-output.mov")
            self.fileUrl = NSURL.fileURL(withPath: outputFielPath)
            self.captureMovieFileOutput?.startRecording(toOutputFileURL: self.fileUrl, recordingDelegate: self)
            self.is_recording = true
        } else {
            self.captureMovieFileOutput?.stopRecording()
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.is_recording = false
        }
        updateLabel();
    }
    
    func updateLabel(){
        if is_recording == true{
            self.record_label.text = "recording...."
        }
        else {
            self.record_label.text = "Tap to Record"
        }
    }
    
    
    
}
