//
//  ViewController.swift
//  MusicPlayer Demo
//
//  Created by Dong Eayon on 10/31/14.
//  Copyright (c) 2014 dongeyoung(personal developer). All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController, PlayListTVCDelegate {
    
    
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var changePlayModeButton: UIButton!
    @IBOutlet weak var currentPlayTime: UILabel!
    // Actually this should be the total duration of the song, lazy to change the label name... :|
    @IBOutlet weak var playBackTime: UILabel!
    @IBOutlet weak var repeatOneSongButton: UIButton!
    
    // Create a variable for systemMusicPlayer instance
    var musicPlayer:MPMusicPlayerController = MPMusicPlayerController.systemMusicPlayer()
    // Create a variable for current playing song media item
    // This is used for showing the title and song image later
    var currentPlayingSong = MPMediaItem()
    // PlayLists - Array
    var playLists = NSArray()
    var playlistID = NSString()
    
    var isPlay = false;

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Notification
        var notificationCenter = NSNotificationCenter.defaultCenter()
        // Notification for playing
        notificationCenter.addObserver(self, selector: "handlePlayingItemChanged", name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: musicPlayer)
        // Notification for playState
        notificationCenter.addObserver(self, selector: "handlePlayState", name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: musicPlayer)
        musicPlayer.beginGeneratingPlaybackNotifications()
        
        if (musicPlayer.playbackState == MPMusicPlaybackState.Playing) {
            playButton.setTitle("Pause", forState: UIControlState.Normal)
            self.isPlay = true
        }

    }

    @IBAction func playButtonAction(sender: UIButton) {
        
        // Start to play songs
        if (self.isPlay) {
            musicPlayer.pause()
            self.isPlay = false
        } else {
            musicPlayer.play()
            self.isPlay = true
        }
        
    }
    
    @IBAction func nextSongButtonAction(sender: UIButton) {
        
        musicPlayer.skipToNextItem()
    }
    
    @IBAction func preSongButtonAction(sender: UIButton) {
        
        musicPlayer.skipToPreviousItem()
        
    }
    
    // Setup Media Item Info
    func setupCurrentMediaItem() {
                
        // When the song can be played, means we can set the current playing song
        currentPlayingSong = musicPlayer.nowPlayingItem
        
        songNameLabel.text = currentPlayingSong.title
        
        // For getting the image needs a few steps, it cannot be directly getted from the item
        var artWork = currentPlayingSong.artwork
        songImageView.image = artWork.imageWithSize(songImageView.bounds.size)
        
        // Get Current Play Time for the song
        var currentPlayTimeInterval = musicPlayer.currentPlaybackTime
        var playTime = formattedPlayTime(currentPlayTimeInterval)
        currentPlayTime.text = playTime
        
        // Get song duration
        playBackTime.text = formattedPlayTime(musicPlayer.nowPlayingItem.playbackDuration)
        
        // Fror the rest song duration, you could use total - current Interval
        // Then can get what u want ~:)
        
        
        // Setup repeat mode to All
        if (musicPlayer.repeatMode != MPMusicRepeatMode.One || musicPlayer.repeatMode != MPMusicRepeatMode.None) {
            musicPlayer.repeatMode = MPMusicRepeatMode.All
            repeatOneSongButton.setTitle("Repeat One Song - All", forState: UIControlState.Normal)
        }
        
    }

    @IBAction func changePlayModeButtonAction(sender: UIButton) {
        
        // MPMusicShuffleModeOff, MPMusicShuffleModeSongs, MPMusicShuffleModeAlbums
        if musicPlayer.shuffleMode == MPMusicShuffleMode.Off {
            musicPlayer.shuffleMode = MPMusicShuffleMode.Songs
            changePlayModeButton.setTitle("Shuffle", forState: UIControlState.Normal)
        } else {
            musicPlayer.shuffleMode = MPMusicShuffleMode.Off
            changePlayModeButton.setTitle("Mode", forState: UIControlState.Normal)
        }
        
    }

    @IBAction func repeatOneSongButtonAction(sender: UIButton) {
        
        // MPMusicRepeatModeOne, MPMusicRepeatModeAll
        if (musicPlayer.repeatMode == MPMusicRepeatMode.One) {
            musicPlayer.repeatMode = MPMusicRepeatMode.All
            repeatOneSongButton.setTitle("Repeat One Song - All", forState: UIControlState.Normal)
        } else if (musicPlayer.repeatMode == MPMusicRepeatMode.All) {
            musicPlayer.repeatMode = MPMusicRepeatMode.None
            repeatOneSongButton.setTitle("Repeat One Song - Off", forState: UIControlState.Normal)
        } else {
            musicPlayer.repeatMode = MPMusicRepeatMode.One
            repeatOneSongButton.setTitle("Repeat One Song - One", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func songListButtonAction(sender: UIButton) {
        
        // For log testing
        println("-> Playlist VC")
        
    }
    
    
    
    // As function name, no more explain :)
    func formattedPlayTime(playTimeInterval:NSTimeInterval) -> String {
        
        var min = String(format: "%.0f", floor(playTimeInterval / 60))
        
        var sec = String(format: "%02.0f", fmod(playTimeInterval, 60))
        
        var playTime = "\(min):\(sec)"
        
        return playTime
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var theSegue = segue.destinationViewController as PlayListTableViewController
        theSegue.playlistIDdelegate = self
        theSegue.playLists = self.playLists.mutableCopy() as NSMutableArray
        theSegue.musicPlayer = self.musicPlayer
        if (self.playlistID.length != 0) {
            theSegue.playlistID = self.playlistID
        }
        
    }
    
    func changePlaylist(#playlistID: String, playlists: NSMutableArray) {
        
        self.playlistID = playlistID
        self.playLists = playlists
        
        if (playLists.count > 0) {
            for playList in playLists {
                
                var playlistID =  "\(playList.valueForProperty(MPMediaPlaylistPropertyPersistentID))"
                
                if playlistID == self.playlistID {
                    var collection = MPMediaItemCollection(items: playList.items)
                    musicPlayer.setQueueWithItemCollection(collection)
                }
                
                musicPlayer.play()
            }
        }
    }
    
    // MARK: - Notification handlers
    func handlePlayingItemChanged() {
        setupCurrentMediaItem()
    }

    func handlePlayState() {
        var playbackState = musicPlayer.playbackState
        
        // Here u may be confused, actually Im also confused.
        // I dont know whether this is a bug for systemMusicPlayer
        // If delete "self.isPlay == true", the Demo player may cause error when first time running with "Play" button
        // So that I cannot trust "MPMusicPlaybackState.Playing", that's the reason I add the variable for trigger the playing state
        
        if (musicPlayer.playbackState == MPMusicPlaybackState.Paused) {
            playButton.setTitle("Play", forState: UIControlState.Normal)
            self.isPlay = false
        } else if (self.isPlay == true || musicPlayer.playbackState == MPMusicPlaybackState.Playing) {
            playButton.setTitle("Pause", forState: UIControlState.Normal)
            self.isPlay = true
        } else {
            playButton.setTitle("Play", forState: UIControlState.Normal)
            self.isPlay = false
        }

    }
}
