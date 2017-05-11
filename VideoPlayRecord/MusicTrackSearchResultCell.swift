//
//  MusicTrackSearchResultCell.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 3/1/17.
//  Copyright © 2017 Pieces. All rights reserved.
//

import Foundation
import UIKit

class MusicTrackSearchResultCell: UITableViewCell {
    
    var iconView = UIImageView()
    var trackLabel = UILabel()
    
    var artistLabel = UILabel()
    
    var lineView = UIView()
    
    var sampleButton = UIButton()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        
        //add subviews
        
        self.contentView.addSubview(iconView);
        self.contentView.addSubview(trackLabel);
        self.contentView.addSubview(lineView);
        self.contentView.addSubview(artistLabel);
        self.contentView.addSubview(sampleButton);
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.iconView.frame = CGRect(x: self.contentView.frame.width * 0.03, y: self.contentView.frame.height * 0.2, width: self.contentView.frame.width * 0.15, height: self.contentView.frame.height * 0.25);
        
        iconView.contentMode = .scaleAspectFit;
        iconView.image = UIImage(named: "track-icon");
        
        self.trackLabel.frame = CGRect(x: self.contentView.frame.width * 0.22, y: self.contentView.frame.height * 0.1, width: self.contentView.frame.width * 0.78, height: self.contentView.frame.height * 0.5);
        self.trackLabel.font = UIFont(name: "Helvetica", size: 15);
        self.trackLabel.textAlignment = .left;
        self.trackLabel.textColor = UIColor.darkGray;
        
        self.artistLabel.frame = CGRect(x: self.contentView.frame.width * 0.22, y: self.contentView.frame.height * 0.6, width: self.contentView.frame.width * 0.78, height: self.contentView.frame.height * 0.4);
        self.artistLabel.font = UIFont(name: "Helvetica", size: 13);
        self.artistLabel.textAlignment = .left;
        self.artistLabel.textColor = UIColor.darkGray;
        
        //add sample button with play icon
        self.sampleButton.frame = CGRect(x: self.contentView.frame.width * 0.8, y: self.contentView.frame.height * 0.2, width: self.contentView.frame.width * 0.15, height: self.contentView.frame.height * 0.25);
        self.sampleButton.setImage(UIImage(named:"play-icon-filled"), for: []);
        self.sampleButton.contentMode = .scaleAspectFit;
        
        
        
        //add bottom seperator
        lineView.frame = CGRect(x: 0, y: self.contentView.frame.height - 1, width: self.contentView.frame.width, height: 1);
        lineView.backgroundColor = UIColor(red: 210.0/255, green: 210.0/255, blue: 210.0/255, alpha: 1.0);
    }
    
    
    func setTitle(title: String){
        self.trackLabel.text = title;
    }
    
    func addArtistNamesToCell(artists: [URL]){
        if artists.count == 0 { return; }
        
        let artistReq = try! SPTArtist.createRequest(forArtists: artists, withAccessToken: Spotify_Auth.session.accessToken); //TODO try without
        
        let task = URLSession.shared.dataTask(with: artistReq) {data, response, error in
            guard error == nil  else{
                print("Error with url session: \(error!)")
                return;
            }
            guard let data = data else {
                print ("Data in respnse empty ********* ");
                return;
            }
            
            do {
                let json = try SPTArtist.artists(from: data, with: response);
                let artistList = json as! [SPTArtist]
                if self.artistLabel.text == nil {
                    self.artistLabel.text = "";
                }
                if artistList.count > 1 {
                    for artist in artistList {
                        self.artistLabel.text = "\(self.artistLabel.text!) \(artist.name!)"
                    }
                }
                else {
                    self.artistLabel.text = "\(artistList.first!.name!)";
                }
                
            }
            catch _ {
                
            }
            
        }
        task.resume();
        
        
    }
    
    
}
