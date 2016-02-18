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
    
    private func seekTrackForRequest(request: Request) -> Track? {
        return vinyl.tracks.first { track in
            trackMatchers.all { matcher in matcher.matchableTrack(request, track: track) }
        }
    }
    
    func playTrack(forRequest request: Request) throws -> (NSData?, NSURLResponse?, NSError?) {
        
        guard let track = self.seekTrackForRequest(request) else {
            throw Error.TrackNotFound
        }
        
        return (track.response.body, track.response.urlResponse, track.response.error)
    }
}
