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
    
    fileprivate func seekTrackForRequest(_ request: Request) -> Track? {
        return vinyl.tracks.first({ track in
            trackMatchers.all { matcher in matcher.matchableTrack(request, track: track) }
        })
    }
    
    func playTrack(forRequest request: Request) throws -> (data: Data?, response: URLResponse?, error: Error?) {
        
        guard let track = self.seekTrackForRequest(request) else {
            throw TurntableError.trackNotFound
        }
        
        return (data: track.response.body as Data?, response: track.response.urlResponse, error: track.response.error)
    }
    
    func trackExists(forRequest request: Request) -> Bool {
        if let _ = self.seekTrackForRequest(request) {
            return true
        }
        
        return false
    }
}
