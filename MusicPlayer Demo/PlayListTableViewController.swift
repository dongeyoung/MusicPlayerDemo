//
//  PlayListTableViewController.swift
//  MusicPlayer Demo
//
//  Created by Dong Eayon on 11/1/14.
//  Copyright (c) 2014 dongeyoung(personal developer). All rights reserved.
//

import UIKit
import MediaPlayer

protocol PlayListTVCDelegate {
    
    func changePlaylist(#playlistID: String, playlists: NSMutableArray)
    
}

class PlayListTableViewController: UITableViewController {
    
    var musicPlayer:MPMusicPlayerController = MPMusicPlayerController.systemMusicPlayer()
    var playLists = NSMutableArray()
    var isHavingPlaylists = true
    var playlistIDdelegate: PlayListTVCDelegate!
    var playlistID = String()
    var playListsCollection = NSArray()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // According to the Apple Doc, you could refer to the Doc
        // And search for keyword "MPMediaQuery" to go more detail info
        // Grouping the key from Playlists
        var query = MPMediaQuery.playlistsQuery()
        
        // Getting playLists from the query
        self.playListsCollection = query.collections
        self.playLists = self.playListsCollection.mutableCopy() as NSMutableArray
        
        
        if playLists.count == 0 {
            playLists.addObject("No Playlist")
            isHavingPlaylists = false
        } else {
            musicPlayer.setQueueWithQuery(query)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playLists.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        if !isHavingPlaylists {
            cell.textLabel.text = "No Playlists"
        } else {
            cell.textLabel.text = playLists[indexPath.row].valueForProperty(MPMediaPlaylistPropertyName) as? String
//            println(playLists[indexPath.row].valueForProperty(MPMediaPlaylistPropertyPersistentID))
            
            var currentPlaylistID = "\(playLists[indexPath.row].valueForProperty(MPMediaPlaylistPropertyPersistentID))"
            if (currentPlaylistID == self.playlistID) {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (isHavingPlaylists) {
            playlistID =  "\(playLists[indexPath.row].valueForProperty(MPMediaPlaylistPropertyPersistentID))"
            self.playlistIDdelegate?.changePlaylist(playlistID: playlistID, playlists: playLists)
        }
        
        self.navigationController!.popViewControllerAnimated(true)
        
    }


}
