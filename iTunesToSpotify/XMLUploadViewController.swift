//
//  XMLViewController.swift
//  iTunesToSpotify
//
//  Created by Alex Beals on 11/22/18.
//  Copyright © 2018 Alex Beals. All rights reserved.
//

import Foundation
import AppKit
import Cocoa

class XMLUploadView : BorderedView {
    let highlightAlpha: CGFloat = 0.1

    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!

        self.registerForDraggedTypes([
            .fileURL,
            .URL
        ])
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        self.layer?.backgroundColor = NSColor(white: 1.0, alpha: highlightAlpha).cgColor
        let res = checkExtension(sender)
        if res {
            print("COPY")
            return .copy
        }
        return NSDragOperation()
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.layer?.backgroundColor = NSColor(white: 1, alpha: 0).cgColor;
    }

    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
         self.layer?.backgroundColor = NSColor(white: 1, alpha: 0).cgColor;
        return true
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        print("perform drag operation")
        guard let pasteboard = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = pasteboard[0] as? String
            else { return false }

        //GET YOUR FILE PATH !!!
        handleXMLUrl(URL(fileURLWithPath: path))
        return true
    }

    func checkExtension(_ draggingInfo: NSDraggingInfo) -> Bool {
        guard let board = draggingInfo.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? NSArray,
            let path = board[0] as? String
            else { return false }

        let suffix = URL(fileURLWithPath: path).pathExtension
        if suffix.lowercased() == "xml" {
            return true
        }
        return false
    }

    override func mouseDown(with theEvent: NSEvent) {
        let openPanel: NSOpenPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = ["xml"]

        openPanel.begin(completionHandler: { (result) -> Void in
            if (result == .OK) {
                DispatchQueue.main.async {
                    openPanel.close()
                }

                for url in openPanel.urls {
                    DispatchQueue.main.async {
                        self.handleXMLUrl(url)
                    }
                }
            }
        })
    }

    func handleXMLUrl(_ url: URL) {
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
}

class XMLUploadViewController: NSViewController {

    @IBOutlet weak var upArrowView: NSImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        upArrowView.unregisterDraggedTypes()

        upArrowView.image = upArrowView.image!.imageTintedWithColor(NSColor(calibratedWhite: 1.0, alpha: 1.0))
    }

    override var representedObject: Any? {
        didSet {

        }
    }
}
