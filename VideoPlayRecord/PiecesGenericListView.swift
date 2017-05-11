//
//  PiecesGenericListView.swift
//  Pods
//
//  Created by William Bertrand on 5/10/17.
//
//

import Foundation
import UIKit


class PiecesGenericListView : UIViewController {
    var userID: String!
    var previewPieces: PiecesPreviewCollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let piecesFrame = CGRect(x: 0, y: self.view.frame.height * 0.1, width: self.view.frame.width, height: self.view.frame.height * 0.9)
        self.previewPieces = PiecesPreviewCollectionView(frame: piecesFrame);
        self.view.addSubview(previewPieces);
        previewPieces.getPiecesForUser(userId: self.userID)
        self.previewPieces.layoutSubviews()
    }
    
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    
}
