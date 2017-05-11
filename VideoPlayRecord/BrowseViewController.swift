//
//  BrowseViewController.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 4/13/17.
//  Copyright © 2017 Pieces. All rights reserved.
//

import Foundation
import UIKit
import GlidingCollection
import Alamofire


class BrowseItemDownloadRequest {
    var title: String!
    var href: String!
    var imageUrlString: String!
}

class BrowseItem {
    
    var image: UIImage!
    var title: String!
    var href: String!
    
}

class BrowseViewController : UIViewController, GlidingCollectionDatasource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var browseFriendsButton: UIButton!
    @IBOutlet weak var browseArtistsButton: UIButton!
    @IBOutlet weak var browseMoodsButton: UIButton!
    
    
    @IBOutlet weak var browseCollection: GlidingCollection!
    var collectionView: UICollectionView!
    var browseItems = ["Artists", "Genres", "Trending", "Friends", "Videos"];
    
    //2d array of browse images..kinda
    var browseArtistsItems: [BrowseItem] = [BrowseItem]()
    var browseGenressItems: [BrowseItem] = [BrowseItem]()
    var browseVideosItems: [BrowseItem] = [BrowseItem]()
    var browseFriendsItems: [BrowseItem] = [BrowseItem]()
    var browseTrendingItems: [BrowseItem] = [BrowseItem]()
    
    var genresBrowseDownloadItems: [BrowseItemDownloadRequest] = [BrowseItemDownloadRequest]()
    var artistsBrowseDownloadItems: [BrowseItemDownloadRequest] = [BrowseItemDownloadRequest]()
    
    var artistsImageUrlStrings: [String] = [String]()
    var genresImageUrlStrings: [String] = [String]()
    
    var currentBrowseType : String!
    var browseTableView: UITableView!
    
    
    var centerLabelFrame: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        var config = GlidingConfig.shared
        config.buttonsFont = UIFont.boldSystemFont(ofSize: 22)
        config.activeButtonColor = .black
        config.inactiveButtonsColor = .lightGray
        GlidingConfig.shared = config
        
        browseCollection.dataSource = self
        
        let nib = UINib(nibName: "BrowseCollectionCell", bundle: nil)
        collectionView = browseCollection.collectionView
        collectionView.register(nib, forCellWithReuseIdentifier: "Cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = browseCollection.backgroundColor
        
        centerLabelFrame = CGRect(x: self.view.frame.width * 0.1, y: self.view.frame.height * 0.2, width: self.view.frame.width * 0.8, height: self.view.frame.height * 0.15);
        
        
        //fill up the browse collection
        self.getBrowseImageUrls();
        self.createFriendsBrowseItems();
        self.createTrendingBrowseItems()
        DispatchQueue.main.async {
            self.browseCollection.reloadInputViews()
            self.browseCollection.collectionView.reloadData();
        }
        
    }
    
    
    
    //TODO: get urls for music and genres
    
    func getBrowseImageUrls(){
        let userBrowseUrl = "https://peaceful-dawn-25448.herokuapp.com/api/user/browse-objects?userID=\(Current_User.uid)&accessToken=\(Spotify_Auth.session.accessToken!)";
        let res = Alamofire.request(userBrowseUrl, method: .get).responseJSON(completionHandler: { response in
            if(response.result.error != nil){
                print("Error Getting browse data: " + response.result.error.debugDescription);
                return;
            }
            
            if let data = response.result.value as! NSDictionary? {
                let artists = data["artists"] as! [NSDictionary]
                for artist in artists{
                    let imgurl = artist["imageurl"] as! String
                    let href = artist["spturi"] as! String
                    let name = artist["name"] as! String
                    let bItem = BrowseItemDownloadRequest()
                    bItem.href = href;
                    bItem.title = name;
                    bItem.imageUrlString = imgurl;
                    self.artistsBrowseDownloadItems.append(bItem);
                }
                let genres = data["genres"] as! [NSDictionary]
                for g in genres {
                    var gIndex = 0
                    if let imgurl = g["imgurl"] as! String? {
                        if(gIndex < 10){
                            let href = g["href"] as! String
                            let name = g["name"] as! String
                            let bItem = BrowseItemDownloadRequest()
                            bItem.href = href;
                            bItem.title = name;
                            bItem.imageUrlString = imgurl;
                            self.genresBrowseDownloadItems.append(bItem);
                            gIndex += 1;
                        }
                        
                    }
                    
                }
                self.createBrowseItems()
                
            }
            
        });
        
        
    }
    
    func createBrowseItems(){
        for item in self.artistsBrowseDownloadItems {
            let imgUrl = URL(string: item.imageUrlString);
            downloadImage(imgURL: imgUrl!, section: 0, name: item.title, hrefString: item.href);
        }
        for item in self.genresBrowseDownloadItems {
            let imgUrl = URL(string: item.imageUrlString);
            downloadImage(imgURL: imgUrl!, section: 1, name: item.title, hrefString: item.href);
            
        }
    }
    
    
    func downloadImage(imgURL: URL, section: Int, name:String, hrefString: String){
        let session = URLSession(configuration: .default);
        //let imgURL = URL(string: imageUrlStr)!
        let downloadAlbumTask = session.dataTask(with: imgURL) { (data, response, error) in
            
            if let e = error {
                print("Error downloading album picture: \(e)")
            }
            else {
                if let res = response as? HTTPURLResponse {
                    if let imageData = data {
                        let image = UIImage(data: imageData);
                        let b: BrowseItem = BrowseItem()
                        b.image = image;
                        b.title = name;
                        b.href = hrefString
                        if(section == 0){
                            print("appending artist image");
                            self.browseArtistsItems.append(b);
                            DispatchQueue.main.async {
                                self.browseCollection.reloadInputViews()
                            }
                        }
                        else if(section == 1){
                            print("appending genre image");
                            self.browseGenressItems.append(b);
                            DispatchQueue.main.async {
                                self.browseCollection.reloadInputViews()
                            }
                        }
                        
                    }
                }
                
            }
            
        }
        //actually perform the task
        downloadAlbumTask.resume()
        
    }
    
    
    func getBrowseElements(){
        var friendsList : [String] = [String]()
        if(currentBrowseType == "friends"){
            
            if(friendsList.count == 0){
                //no friends, LOSER!
                let resLabel: UILabel = UILabel(frame: self.centerLabelFrame);
                resLabel.text = "You are not following anyone!"
                resLabel.contentMode = .center;
                resLabel.textAlignment = .center;
                resLabel.font = UIFont.systemFont(ofSize: 14);
                self.view.addSubview(resLabel);
            }
            //else set up the table view for friends
            
            
            
        }
        
    }
    
    
    
    //Mark gliding collection view section
    
    func numberOfItems(in collection: GlidingCollection) -> Int {
        return browseItems.count;
    }
    
    func glidingCollection(_ collection: GlidingCollection, itemAtIndex index: Int) -> String {
        return "- " + browseItems[index];
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let selection = browseCollection.expandedItemIndex;
        if (selection == 0){
            return self.browseArtistsItems.count;
        }
        else if(selection == 1){
            return self.browseGenressItems.count;
        }
        else if(selection == 2){
            return self.browseTrendingItems.count;
        }
        else if(selection == 3){
            return self.browseFriendsItems.count;
        }
        else {
            return 0
        }
        //return browseImages[section].count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? BrowseCollectionCell else { return UICollectionViewCell() }
        let section = browseCollection.expandedItemIndex
        //artists
        if(section == 0){
            cell.imageView.image = browseArtistsItems[indexPath.row].image
            cell.titleLabel.text = browseArtistsItems[indexPath.row].title
            cell.itemHref = browseArtistsItems[indexPath.row].href
        }
        else if (section == 1){
            cell.imageView.image = browseGenressItems[indexPath.row].image;
            cell.titleLabel.text = browseGenressItems[indexPath.row].title;
            cell.itemHref = browseGenressItems[indexPath.row].href;
        }
        else if (section == 2){
            cell.imageView.image = browseTrendingItems[indexPath.row].image;
            cell.titleLabel.text = browseTrendingItems[indexPath.row].title;
            cell.itemHref = browseTrendingItems[indexPath.row].href;
        }
        else if (section == 3){
            cell.imageView.image = browseFriendsItems[indexPath.row].image;
            cell.titleLabel.text = browseFriendsItems[indexPath.row].title;
            cell.itemHref = browseFriendsItems[indexPath.row].href;
        }
        else {
                //TODO: videos or pieces user or something ... :P
        }
        cell.imageView.contentMode = .scaleAspectFit;
        
        
        cell.contentView.clipsToBounds = true
        
        let layer = cell.layer
        let config = GlidingConfig.shared
        layer.shadowOffset = config.cardShadowOffset
        layer.shadowColor = config.cardShadowColor.cgColor
        layer.shadowOpacity = config.cardShadowOpacity
        layer.shadowRadius = config.cardShadowRadius
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = browseCollection.expandedItemIndex
        let item = indexPath.item
        print("Selected item #\(item) in section #\(section)")
        if (section == 0){
            //artists
            let artistName = browseArtistsItems[item].title;
            self.showBrowseFeedView(title: artistName!);
        }
        else if(section == 1){
            //genres
            let genreName = browseGenressItems[item].title;
            self.showBrowseFeedView(title: genreName!);
        }
        else if(section == 2){
            //trending
            self.showBrowseFeedView(title: "Trending");
        }
        else if(section == 3){
            //friends
            print("SECTION 3")
            self.showUserSearchView()
            if indexPath.row >= browseFriendsItems.count - 1 {
                //search for friends pressed
                //self.showUserSearchView()
            }
            else {
                //go to friend profile view
            }
            
        }
        else {
            
        }
        
        
    }
    
    
    //todo: get friends from backgroung
    func createFriendsBrowseItems() {
        //get list of friends from user account
        //let friendsRetreived = data
        //for friend in friendsRetreived{
        
        //}
        
        let searchItem = BrowseItem()
        searchItem.image = UIImage(named:"search-img");
        searchItem.title = "Search For Friends";
        searchItem.href = "this://searchView";
        self.browseFriendsItems.append(searchItem);
    }
    
    let testTrendingTopicsArray = ["outdoors", "transportation", "rain", "flower"];
    func createTrendingBrowseItems() {
        //todo getTrendingTopics from backend
        let trendingTopics = testTrendingTopicsArray
        for topic in trendingTopics{
            let searchItem = BrowseItem()
            searchItem.image = UIImage(named:"\(topic)-img");
            searchItem.title = topic;
            searchItem.href = "this://trending-\(topic)";
            self.browseTrendingItems.append(searchItem);
        }
    }
    
    func showUserSearchView(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "UserSearchViewControllerInstance") as! UserSearchViewController
        self.present(controller, animated: true, completion: nil)
    }
    
    
    func showBrowseFeedView(title: String){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "BrowseFeedViewInstance") as! BrowseFeedView
        controller.titleText = title;
        controller.browseTitleLabel.text = title
        //controller.hrefForPieces = some kind of search paramete/ url / quesry
        //todo controller.browseType = ENUM
        self.present(controller, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    @IBAction func browseByFriendsPressed(_ sender: Any) {
        self.browseFriendsButton.isHidden = true
        self.browseArtistsButton.isHidden = true
        self.browseMoodsButton.isHidden = true
        
        self.currentBrowseType = "friends"
        self.getBrowseElements();
        
    }
    
    
    
    
}
