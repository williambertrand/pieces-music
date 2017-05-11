//
//  LoadMoreCollectionViewCell.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 4/22/17.
//  Copyright © 2017 Pieces. All rights reserved.
//

import Foundation
import UIKit


class LoadMoreCollectionViewCell : UICollectionViewCell {
    
    var textLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textLabel = UILabel(frame: CGRect(x: frame.width * 0.05, y: frame.height * 0.25  , width: frame.width * 0.9, height: frame.height * 0.5));
        textLabel.font = UIFont(descriptor: UIFontDescriptor.init(name: "Helvetica", size: 16), size: 16);
        textLabel.textAlignment = .center
        textLabel.text = "Tap To Load More....";
        self.contentView.addSubview(textLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
