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
    let trackMatcher: TrackMatcher
    
    private func seekTrackForRequest(request: Request) -> Track? {
        
        return vinyl.tracks.filter { trackMatcher.matchableTrack(request, track: $0) }.first
    }
    
    func playTrack(forRequest request: Request) -> (NSData?, NSURLResponse?, NSError?) {
        
        guard let track = self.seekTrackForRequest(request) else {
            fatalError("💥 No 🎶 recorded and matchable with request: \(request.debugDescription) 😩")
        }
        
        return (track.response.body, track.response.urlResponse, track.response.error)
    }
}
