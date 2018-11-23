//
//  ViewController.swift
//  iTunesToSpotify
//
//  Created by Alex Beals on 11/22/18.
//  Copyright © 2018 Alex Beals. All rights reserved.
//

import Cocoa
import AppKit

class Track: NSObject {
    var trackID: Int = 0
    var totalTime: String = ""
    var name: String = ""
    var artist: String = ""
    var album: String = ""
    var spotifyURI: String = ""
    var attemptedDownload: Bool = false

    init(_ dict: NSDictionary) {
        if let trackID = dict.object(forKey: "Track ID") as? Int {
            self.trackID = trackID
        }
        if let totalTime = dict.object(forKey: "Total Time") as? String {
            self.totalTime = totalTime
        }
        if let name = dict.object(forKey: "Name") as? String {
            self.name = name
        }
        if let artist = dict.object(forKey: "Artist") as? String {
            self.artist = artist
        }
        if let album = dict.object(forKey: "Album") as? String {
            self.album = album
        }
    }

    func findSpotifyURI(_ completionHandler: @escaping () -> Void = {}) {
        if (name == "") {
            attemptedDownload = true
            completionHandler()
            return
        }
        SpotifyHelper.shared.findTrack(withName: name, artist: artist, completionHandler: { (trackURI) -> Void in
            self.attemptedDownload = true

            if (trackURI != "") {
                self.spotifyURI = trackURI;
            }
            completionHandler()
        })
    }
}

class Playlist: NSObject {
    var playlistID : String = ""
    var playlistPersistentID : String = ""
    var name : String = ""
    var trackIDs: [Int] = []

    init(_ dict: NSDictionary) {
        if let name = dict.object(forKey: "Name") as? String {
            self.name = name
        }
        if let playlistID = dict.object(forKey: "Playlist ID") as? String {
            self.playlistID = playlistID
        }
        if let playlistPersistentID = dict.object(forKey: "Playlist Persistent ID") as? String {
            self.playlistPersistentID = playlistPersistentID
        }
        if let playlistDictItems = dict.object(forKey: "Playlist Items") as? [NSDictionary] {
            var trackIDs: [Int] = []
            for playlistDictItem in playlistDictItems {
                if let playlistTrackID = playlistDictItem.object(forKey: "Track ID") as? Int {
                    trackIDs.append(playlistTrackID)
                }
            }
            self.trackIDs = trackIDs
        }
    }

    func getTracks(trackList: [Int: Track], serially: Bool, completionHandler: @escaping ([Track]) -> Void) {
        var finishedTracks: [Track] = []
        if (trackIDs.count == 0) {
            completionHandler([])
        }
        if (serially) {
            var processTrackWithIndex: (Int) -> Void = {_ in }
            processTrackWithIndex = { index -> Void in
                trackList[self.trackIDs[index]]?.findSpotifyURI({
                    finishedTracks.append(trackList[self.trackIDs[index]]!)
                    if (index == self.trackIDs.count - 1) {
                        completionHandler(finishedTracks)
                        return
                    } else {
                        processTrackWithIndex(index + 1)
                    }
                })
            }
            processTrackWithIndex(0)
        } else {
            for track in trackIDs {
                trackList[track]?.findSpotifyURI({
                    finishedTracks.append(trackList[track]!)
                    if (finishedTracks.count == self.trackIDs.count) {
                        completionHandler(finishedTracks)
                    }
                })
            }
        }
    }
}

class ViewController: NSViewController {
    @IBAction func selectXMLFile(_ sender: NSButtonCell) {
        let openPanel: NSOpenPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = ["xml"]

        openPanel.begin(completionHandler: { (result) -> Void in
            if (result == .OK) {
                DispatchQueue.main.async {
                    openPanel.close()

                    sender.isEnabled = false
                }

                for url in openPanel.urls {
                    DispatchQueue.main.asyncAfter(
                        deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(0),
                        execute: {
                            let xmlFile = NSDictionary(contentsOf: url)

                            // Pull out track information
                            guard let trackInfoDict = xmlFile?.object(forKey: "Tracks") as? NSDictionary else {
                                // whoops
                                return
                            }

                            var tracks: [Int: Track] = [:]
                            for trackDict in trackInfoDict {
                                let track = Track(trackDict.value as! NSDictionary)
                                tracks[track.trackID] = track
                            }

                            // Pull out playlist information
                            guard let playlistDicts = xmlFile?.object(forKey: "Playlists") as? [NSDictionary] else {
                                // whoops
                                return
                            }

                            var playlists: [Playlist] = []
                            for playlistDict in playlistDicts {
                                let playlist = Playlist(playlistDict)

                                playlists.append(playlist)
                            }

                            for playlist in playlists {
                                print("\(playlist.name):")
                                if playlist.name == "FF Family Favorites" {
                                    playlist.getTracks(trackList: tracks, serially: true, completionHandler: { t -> Void in
                                        var trackNames = ""
                                        for tr in t {
                                            if tr.spotifyURI != "" {
                                                trackNames += "\(tr.spotifyURI)\n"
                                            }
                                        }
                                        print(trackNames)
                                    })
                                }
                            }
                        }
                    )
                }
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

