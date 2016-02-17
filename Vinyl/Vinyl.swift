//
//  Vinyl.swift
//  Vinyl
//
//  Created by Rui Peres on 12/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

struct Vinyl {
    
    let tracks: [Track]
    
    init(plastic: Plastic) {
        tracks = plastic.map(Track.init)
    }
    
    init(tracks: [Track]) {
        
        self.tracks = tracks
    }
}

struct VinylFactory {
    
    static func createBadVinyl(url: NSURL, statusCode: Int, error: NSError? = nil, headers: HTTPHeaders = [:]) -> Vinyl {
        
        guard
            let response = NSHTTPURLResponse(URL: url, statusCode: statusCode, HTTPVersion: nil, headerFields: headers)
        else {
            fatalError("We weren't able to create the Vinyl 😫")
        }
        
        let track = Track(response: Response(urlResponse: response, error: error))
        return Vinyl(tracks: [track])
    }
    
    static func createVinyl(url: NSURL, body: NSData? = nil, headers: HTTPHeaders = [:]) -> Vinyl {
        
        guard
            let response = NSHTTPURLResponse(URL: url, statusCode: 200, HTTPVersion: nil, headerFields: headers)
        else {
                fatalError("We weren't able to create the Vinyl 😫")
        }
        
        let track = Track(response: Response(urlResponse: response, body: body))
        return Vinyl(tracks: [track])
    }
}

