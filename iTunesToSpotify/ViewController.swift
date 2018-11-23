//
//  ViewController.swift
//  iTunesToSpotify
//
//  Created by Alex Beals on 11/22/18.
//  Copyright © 2018 Alex Beals. All rights reserved.
//

import Cocoa
import AppKit

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
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

