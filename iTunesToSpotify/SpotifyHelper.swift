//
//  SpotifyHelper.swift
//  iTunesToSpotify
//
//  Created by Alex Beals on 11/22/18.
//  Copyright © 2018 Alex Beals. All rights reserved.
//

import Foundation

class SpotifyHelper: NSObject {
    static let shared = SpotifyHelper()
    var authToken: String = ""

    override init() {
        super.init()
    }

    public func initialize(_ callbackHandler: () -> Void = {}) {
        if (authToken == "") {
            getAuthToken(callbackHandler)
        }
    }

    // Set up the authentication
    private func getAuthToken(_ callbackHandler: () -> Void) {
        var request = URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!)
        let client_id = "3779c98dc12a4cadbe0ccb1167dfb8e9"
        let client_secret = "87fae4aa4cb5405fbc305f16af32a95c"
        let credentials = Data("\(client_id):\(client_secret)".utf8).base64EncodedString()

        request.httpMethod = "POST"
        request.httpBody = "grant_type=client_credentials".data(using: String.Encoding.ascii, allowLossyConversion: true)!
        request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary else {
                    return
                }
                self.authToken = json.object(forKey: "access_token") as! String
                print(self.authToken)
            } catch {
                print("Errored")
            }
        }).resume()
    }

    public func findTrack(withName name: String, artist: String, completionHandler: @escaping (String) -> Void) {
        if (authToken == "") {
            print("Not initialized with an auth token.  Initializing now.")
            self.initialize({
                self.findTrack(withName: name, artist: artist, completionHandler: completionHandler)
            })
            return
        }

        // Build the request string for the track
        var requestString = "https://api.spotify.com/v1/search?q="
        requestString += name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        if (artist != "") {
            requestString += "+artist:"
            requestString += artist.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        }
        requestString += "&type=track&market=US&limit=1"

        var request = URLRequest(url: URL(string: requestString)!)

        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary else {
                    print("Failed to serialize")
                    completionHandler("")
                    return
                }
                if let itemsArray = json.value(forKeyPath: "tracks.items") as? NSArray {
                    if let itemInfo = itemsArray.firstObject as? NSDictionary {
                        if let trackURI = itemInfo.value(forKey: "uri") as? String {
                            completionHandler(trackURI)
                            return
                        }
                    }
                }
                print("Failed to find trackURI")
                print(json)
                completionHandler("")
            } catch {
                print("Errored")
            }
        }).resume()
    }
}

