//
//  Player.swift
//  Vinyl
//
//  Created by David Rodrigues on 16/02/16.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

struct Player {
    
    let vinyl: Vinyl
    let trackMatchers: [TrackMatcher]
    
    fileprivate func seekTrack(for request: Request) -> Track? {
        return vinyl.tracks.first { track in
            trackMatchers.all { matcher in matcher.matchable(track: track, for: request) }
        }
    }
    
    func playTrack(for request: Request) throws -> (data: Data?, response: URLResponse?, error: Error?) {
        
        guard let track = self.seekTrack(for: request) else {
            throw TurntableError.trackNotFound
        }
        
        return (data: track.response.body as Data?, response: track.response.urlResponse, error: track.response.error)
    }
    
    func trackExists(for request: Request) -> Bool {
        if let _ = self.seekTrack(for: request) {
            return true
        }
        
        return false
    }
}
