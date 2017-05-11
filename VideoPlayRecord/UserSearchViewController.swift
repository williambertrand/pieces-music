//
//  UserSearchViewController.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 4/21/17.
//  Copyright © 2017 Pieces. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class UserSearchViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    let userRef = FIRDatabase.database().reference(withPath: "public-user-data");
    var users = [UserObject]()
    var searchQuery: String!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var userTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tableFrame = CGRect(x: 0, y: searchBar.frame.height + self.view.frame.height * 0.05, width: self.view.frame.width, height: self.view.frame.height - searchBar.frame.height);
        userTableView = UITableView(frame: tableFrame);
        userTableView.delegate = self
        userTableView.dataSource = self
        userTableView.register(UINib(nibName: "UserSearchResultCell", bundle: nil), forCellReuseIdentifier: "userCell")
        self.view.addSubview(userTableView)
        
        searchBar.delegate = self
        searchBar.placeholder = "Search for a friend..."
        
        
    }
    
    
    
    func loadRelatedUsers(){
        
    }
    
    
    func searchForUserByName(name:String){
        
        
    }
    //UITableView methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UserSearchResultCell!;
        cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! UserSearchResultCell
        
        cell.userNameLabel.text = users[indexPath.row].name;
        cell.userEmailLabel.text = users[indexPath.row].email;
        cell.userLocationLabel.text = "Princeton"
        
        
        //cell.userLocationLabel.text = users[indexPath.row].locationDesc
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showUserProfileView(user: self.users[indexPath.row]);
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height * 0.15;
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.users.removeAll()
        print("searching..")
        self.searchQuery = searchText.lowercased();
        findUsers(text: searchText);
    }
    

    func findUsers(text: String)->Void{
        self.userRef.queryOrdered(byChild: "search-name").queryStarting(atValue: text).observe(.value, with: { snapshot in
            print("FOUND:");
            var user: UserObject!
            
            if let userDict = snapshot.value as? NSDictionary {
                
                let userNames = userDict.allKeys as! [String]
                
                for u in userNames {
                    //let userRefObj = u as! AnyObject
                    let userRefObj = userDict[u] as! NSDictionary
                    let name = userRefObj["name"] as! String
                    print("Found user: \(name)")
                    user = UserObject(dict: userRefObj);
                    self.users.append(user)
                    DispatchQueue.main.async {
                        self.userTableView.reloadData();
                    }
                }
                
            }
            
            
        })
    }
    
    func showUserProfileView(user: UserObject){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "UserProfileViewInstance") as! UserProfileViewController
        controller.user = user;
        self.present(controller, animated: true, completion: nil)
    }
    
    
}
