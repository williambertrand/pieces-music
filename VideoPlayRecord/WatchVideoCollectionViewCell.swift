//
//  WatchVideoCollectionViewCell.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 11/13/16.
//  Copyright © 2016 Will Bert. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit

class WatchVideoCollectionViewCell: UICollectionViewCell {
    
    var textLabel: UILabel!
    
    
    //Text labels
    var postedByLabel: UILabel!
    var postedByImageView: UIImageView!
    var pieceTagsLabel:UILabel!
    var dateLabel: UILabel!
    
    var loadingLabel: UILabel!
    
    var player : AVPlayer!
    var avLayer : AVPlayerLayer!
    
    var isPlaying: Bool = false
    var instantiated: Bool = false
    var tempPieceImageView : UIImageView! //TODO?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: 25));
        textLabel.font = UIFont.systemFont(ofSize: 15);
        textLabel.textAlignment = .center
        textLabel.text = "watch cell";
        //contentView.addSubview(textLabel)
        self.pieceTagsLabel = UILabel();
        pieceTagsLabel.text = "";
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.postedByImageView = UIImageView()
        self.contentView.addSubview(postedByImageView);
        
        //self.layoutSubviews()
        
        //self.loadingLabel = UILabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPiece(piece: PieceObj){
        //add postedby label
        self.postedByLabel = UILabel()
        self.postedByLabel.font = UIFont(name: "Helvetica", size: 14);
        self.postedByLabel.textColor = UIColor.darkGray
        self.postedByLabel.text = "";
        //self.postedByImageView = UIImageView()
        //self.contentView.addSubview(postedByImageView)
        //self.contentView.addSubview(postedByLabel);
        
        //self.loadingLabel = UILabel()
        //self.loadingLabel.frame = CGRect(x: self.contentView.frame.width * 0.3, y: self.contentView.frame.height * 0.4, width: self.contentView.frame.width * 0.4, height: self.contentView.frame.height * 0.25);
        //self.loadingLabel.text = "Loading Video";
        
        
    }
    
    func setPieceUser(userName: String){
        self.postedByLabel = UILabel()
        self.postedByLabel.frame = CGRect(x: self.contentView.frame.width * 0.11, y: 0, width: self.contentView.frame.width / 2, height: self.contentView.frame.height * 0.2);
        self.postedByLabel.font = UIFont(name: "Helvetica", size: 14);
        self.postedByLabel.textColor = UIColor.darkGray
        self.postedByLabel.text = userName;
        self.contentView.addSubview(postedByLabel);
        //self.postedByImageView = UIImageView()
        //self.contentView.addSubview(postedByImageView)
//        self.loadingLabel = UILabel()
//        self.loadingLabel.frame = CGRect(x: self.contentView.frame.width * 0.3, y: self.contentView.frame.height * 0.4, width: self.contentView.frame.width * 0.4, height: self.contentView.frame.height * 0.25);
//        self.loadingLabel.text = "Loading Video";
        //self.contentView.addSubview(loadingLabel);
    }
    
    func setPieceTopics(topicList:[String]){
        var topicStr: String = "";
        var c = 0;
        //print("updating topic: " + topicList[0]);
        for str in topicList {
            if(c == 0){
                topicStr = str;
                c = c + 1
            }
            else if(c < 3){
                topicStr = topicStr + ", " + str
                c = c + 1
            }
            else{
                
            }
            
        }
        
        
        let topicFrame = CGRect(x: self.contentView.frame.width * 0.5, y: 0, width: self.contentView.frame.width * 0.46, height: self.contentView.frame.height * 0.2);
        self.pieceTagsLabel = UILabel(frame: topicFrame);
        self.pieceTagsLabel.textAlignment = .right;
        self.pieceTagsLabel.font = UIFont(name: "Helvetica", size: 14);
        self.pieceTagsLabel.textColor = UIColor.darkGray
        self.pieceTagsLabel.text = topicStr;
        self.contentView.addSubview(pieceTagsLabel);
        
        
    }
    
    func showTemporaryVideo(){
        self.tempPieceImageView = UIImageView(frame: self.contentView.frame);
        self.tempPieceImageView.image = UIImage(named: "temp-piece");
        self.tempPieceImageView.contentMode = .scaleAspectFit;
        //self.contentView.addSubview(self.tempPieceImageView);
    }
    
    override func layoutSubviews() {
        //self.postedByLabel.frame = CGRect(x: self.contentView.frame.width * 0.22, y: self.contentView.frame.height * 0.1, width: self.contentView.frame.width / 2, height: self.contentView.frame.height * 0.2);
        self.postedByImageView.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.width * 0.1, height: self.contentView.frame.height * 0.15)
        self.postedByImageView.image = UIImage(named: "default-profile");
        self.postedByImageView.contentMode = .scaleAspectFit
        self.postedByImageView.layer.cornerRadius = self.postedByImageView.frame.width / 2
        self.postedByImageView.clipsToBounds = true;
        //self.pieceTagsLabel.frame = CGRect(x: self.contentView.frame.width * 0.5, y: 0, width: self.contentView.frame.width * 0.5, height: self.contentView.frame.height * 0.2);
    }
    
    func addVideo(downloadFilePath: String){
        if self.tempPieceImageView != nil {
            //self.tempPieceImageView.removeFromSuperview();
        }
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
        
        
        //TODO: frame for the player should be smaller than the contentview so
        //as to add user who posted, and date, and tags
        
        let playerFrame = CGRect(x: 0, y: self.contentView.frame.height * 0.15, width: self.contentView.frame.width, height: self.contentView.frame.height * 0.85);
        avPlayerLayer.frame = playerFrame;
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.contentView.layer.insertSublayer(avPlayerLayer, at: 0);
        self.instantiated = true
        //player.play()
        //self.loadingLabel.removeFromSuperview();
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
    
    func addImageForUSer(imageURL: String){
        
    }
    
    
    func tapUser(){
        //display user profile view for that user
    }
    
}
