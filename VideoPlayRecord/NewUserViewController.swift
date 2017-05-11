//
//  NewUserViewController.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 5/2/17.
//  Copyright © 2017 Pieces. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class NewUserViewController: UIViewController {
    
    let userInfoRef = FIRDatabase.database().reference(withPath: "public-user-data")
    
    @IBOutlet weak var connectServiceButton: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var colorTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.connectServiceButton.layer.cornerRadius = 4;
        
    }
    
    
    @IBOutlet weak var startPressed: UIButton!
    
    
    @IBAction func startButtonPressed(_ sender: Any) {
        self.saveInfo()
    }
    
    func saveInfo(){
        
        let userID = FIRAuth.auth()?.currentUser?.uid ?? "error"
        var name = "none"
        var phone = "none"
        var location = "none"
        var color = "none"
        var searchName = "aaaa"
        
        if (nameTextField.text == nil){
            name = nameTextField.text!
            searchName = name.lowercased()
        }
        
        if(phoneTextField.text != nil){
            phone = phoneTextField.text!
        }
        
        if(locationTextField.text != nil){
            location = locationTextField.text!
        }
        
        if(colorTextField.text != nil){
            color = colorTextField.text!
        }
        
        let infoDict = [ "user_id":userID, "userid":userID, "name": name, "phone": phone, "location":location, "fav-color":color, "search-name":searchName, "pieces": 0, "followers": 0, "following": 0] as [String : Any]
        
        userInfoRef.child((FIRAuth.auth()?.currentUser?.uid)!).setValue(infoDict);
    }
    
    
    

}
