//
//  MergeVideoViewController.swift
//  VideoPlayRecord
//
//  Created by Andy on 2/1/15.
//  Copyright (c) 2015 Will Bert. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import AssetsLibrary
import MediaPlayer
import CoreMedia

class MergeVideoViewController: UIViewController {
  var firstAsset: AVAsset?
  var secondAsset: AVAsset?
  var audioAsset: AVAsset?
  var loadingAssetOne = false

  @IBOutlet var activityMonitor: UIActivityIndicatorView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func savedPhotosAvailable() -> Bool {
    if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
      let alert = UIAlertController(title: "Not Available", message: "No Saved Album found", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
      present(alert, animated: true, completion: nil)
      return false
    }
    return true
  }

  func startMediaBrowserFromViewController(_ viewController: UIViewController!, usingDelegate delegate : (UINavigationControllerDelegate & UIImagePickerControllerDelegate)!) -> Bool {
    if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
      return false
    }

    let mediaUI = UIImagePickerController()
    mediaUI.sourceType = .savedPhotosAlbum
    mediaUI.mediaTypes = [kUTTypeMovie as NSString as String]
    mediaUI.allowsEditing = true
    mediaUI.delegate = delegate
    present(mediaUI, animated: true, completion: nil)
    return true
  }

  @IBAction func loadAssetOne(_ sender: AnyObject) {
    if savedPhotosAvailable() {
      loadingAssetOne = true
      startMediaBrowserFromViewController(self, usingDelegate: self)
    }
  }


  @IBAction func loadAssetTwo(_ sender: AnyObject) {
    if savedPhotosAvailable() {
      loadingAssetOne = false
      startMediaBrowserFromViewController(self, usingDelegate: self)
    }
  }

  
  @IBAction func loadAudio(_ sender: AnyObject) {
    
    
  }
  
  
  @IBAction func merge(_ sender: AnyObject) {
   
    
  }
  
}

extension MergeVideoViewController: UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    let mediaType = info[UIImagePickerControllerMediaType] as! NSString
    dismiss(animated: true, completion: nil)

    if mediaType == kUTTypeMovie {
      let avAsset = AVAsset(url:info[UIImagePickerControllerMediaURL] as! URL)
      var message = ""
      if loadingAssetOne {
        message = "Video one loaded"
        firstAsset = avAsset
      } else {
        message = "Video two loaded"
        secondAsset = avAsset
      }
      let alert = UIAlertController(title: "Asset Loaded", message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
      present(alert, animated: true, completion: nil)
    }
  }

}

extension MergeVideoViewController: UINavigationControllerDelegate {

}

extension MergeVideoViewController: MPMediaPickerControllerDelegate {

}
