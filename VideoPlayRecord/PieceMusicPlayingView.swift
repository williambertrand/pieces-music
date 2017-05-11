//
//  PieceMusicPlayingView.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 3/10/17.
//  Copyright © 2017 Pieces. All rights reserved.
//

import Foundation
import UIKit

class PieceMusicPlayingView : UIView {
    
    
    //song title label
    var songLabel: UILabel!
    //artist title label
    var artistLabel: UILabel!
    
    //album image view
    var albumView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        songLabel = UILabel();
        artistLabel = UILabel();
        albumView = UIImageView();
        
        //add views
        self.addSubview(songLabel);
        self.addSubview(artistLabel);
        self.addSubview(albumView);
        albumView.image = UIImage(named: "sound-wave")
        
        self.layer.cornerRadius = 5;
        self.layer.backgroundColor = UIColor.lightGray.cgColor; //TODO color constants
        //TODO color of title anbd artist label
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        let width = self.frame.width;
        let height = self.frame.height;
        
        albumView.frame = CGRect(x: width * 0.05, y: height * 0.1, width: width * 0.25, height: height * 0.8);
        
        songLabel.frame = CGRect(x: width * 0.3, y: height * 0.1, width: width * 0.7, height: height * 0.4);
        songLabel.font = UIFont(name: "Helvetica", size: 10);
        
        artistLabel.frame = CGRect(x: width * 0.3, y: height * 0.55, width: width * 0.7, height: height * 0.4);
        artistLabel.font = UIFont(name: "Helvetica", size: 10);
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class PiecesMusicAdvertView: UIView {
    
    var advertiserName: String!;
    var nameLabel: UILabel!
    var AdvertiserLogoImage : UIImage!
    var logoView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.advertiserName = ""
        self.logoView = UIImageView();
        logoView.image = UIImage(named: "pepsi-ex");
        logoView.contentMode = .scaleAspectFit;
        self.nameLabel = UILabel()
        self.addSubview(logoView);
        self.addSubview(nameLabel);
        
        self.layer.cornerRadius = 2;
        self.layer.backgroundColor = UIColor.lightGray.cgColor;
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        let width = self.frame.width;
        let height = self.frame.height;
        
        logoView.frame = CGRect(x: width * 0.6, y: height * 0.1, width: width * 0.35, height: height * 0.8);
        
        nameLabel.frame = CGRect(x: width * 0.02, y: height * 0.15, width: width * 0.7, height: height * 0.6);
        nameLabel.text = "pepsi"
        nameLabel.font = UIFont(name: "Helvetica", size: 18);
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}





