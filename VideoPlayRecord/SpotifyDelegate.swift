//
//  SpotifyDelegate.swift
//  VideoPlayRecord
//
//  Created by William Bertrand on 2/26/17.
//  Copyright © 2017 Pieces. All rights reserved.
//

import Foundation



class SpotifyDelegate {
    
    var userPlaylists : SPTPlaylistList!
    var currentUser : SPTUser!
    
    func getUsersPlaylists(withToken: String!) -> SPTPlaylistList {
        self.getCurrentUser(withToken: withToken) { (user) in
            SPTPlaylistList.playlists(forUser: user.canonicalUserName, withAccessToken: withToken, callback: { (error, playlistAny) in
                guard let playlists = playlistAny as? SPTPlaylistList else { return }
                //TODO
                
                self.userPlaylists = playlists
            })
        }
        return SPTPlaylistList()
    }
    
    func getCurrentUser(withToken: String!, completion: @escaping (SPTUser) -> Void) {
        SPTUser.requestCurrentUser(withAccessToken: withToken) { (error, user) in
            guard let userObject = user as? SPTUser else { return }
            self.currentUser = userObject;
            completion(userObject)
        }
    }
}
