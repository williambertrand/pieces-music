//
//  WatchVideoCollectionViewCell.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 11/13/16.
//  Copyright © 2016 Ray Wenderlich. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit

class WatchVideoCollectionViewCell: UICollectionViewCell {
    
    var textLabel: UILabel!
    var player : AVPlayer!
    var avLayer : AVPlayerLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: 25));
        textLabel.font = UIFont.systemFont(ofSize: 15);
        textLabel.textAlignment = .center
        textLabel.text = "watch cell";
        //contentView.addSubview(textLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playVideo(downloadFilePath: String){
        textLabel.text = "\(downloadFilePath)";
        print("playvideo: \(downloadFilePath)");
        
//        player = AVPlayer(url: path);
//        avLayer = AVPlayerLayer(player: player);
//        player?.actionAtItemEnd = .none;
//        let vRect = CGRect(x: 0, y: 0, width: self.contentView.frame.height, height: self.contentView.frame.height);
//        avLayer.frame = vRect;
//        avLayer.backgroundColor = UIColor.blue.cgColor;
//        self.contentView.layer.addSublayer(avLayer);
//        player.play();
        
        let player = AVPlayer(url: NSURL(fileURLWithPath: downloadFilePath) as URL);
        //let playerController = AVPlayerViewController()
        
        //playerController.player = player
        //self.addChildViewController(playerController)
        //self.view.addSubview(player);
        //playerController.view.frame = self.view.frame
        let avPlayerLayer = AVPlayerLayer(player: player);
        avPlayerLayer.frame = self.contentView.frame;
        self.contentView.layer.insertSublayer(avPlayerLayer, at: 0);
        
        player.play()
        
        
        
        
        
    }
    
}
