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
    
    var isPlaying: Bool = false
    
    var instantiated: Bool = false
    
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
    
    func displayVideo(downloadFilePath: String){
        if (instantiated == true) {
            self.player = nil
            if self.contentView.layer.sublayers?.count != 0 {
                print("clearing sublayers");
                for l in (self.contentView.layer.sublayers)! {
                    l.removeFromSuperlayer()
                }
            }
        }
        self.player = AVPlayer(url: NSURL(fileURLWithPath: downloadFilePath) as URL);
        let avPlayerLayer = AVPlayerLayer(player: player);
        avPlayerLayer.frame = self.contentView.frame;
        self.contentView.layer.insertSublayer(avPlayerLayer, at: 0);
        self.instantiated = true
        //player.play()
    }
    
    func playVideo(){
        print("play video called");
        if isPlaying == false {
            player.play()
            self.isPlaying = true
        }
        else {
            player.pause()
            self.isPlaying = false
        }
    }
    
}
