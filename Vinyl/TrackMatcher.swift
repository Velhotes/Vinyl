//
//  TrackMatcher.swift
//  Vinyl
//
//  Created by David Rodrigues on 16/02/16.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

protocol TrackMatcher {
    func matchableTrack(request: Request, track: Track) -> Bool
}

// We cannot use a struct, otherwise we need to mark `-matchableTrack` as mutating and that breaks protocol conformance (rdar://21966810)
final class UniqueTrackMatcher: TrackMatcher {

    private var availableTracks: [Track]
    
    init(availableTracks: [Track]) {
        self.availableTracks = availableTracks
    }
    
    func matchableTrack(_: Request, track: Track) -> Bool {
        
        if let index = availableTracks.indexOf(track) {
            availableTracks.removeAtIndex(index)
            return true
        }
        
        return false
    }
}

struct TypeTrackMatcher: TrackMatcher {
    
    let requestMatcherRegistry: RequestMatcherRegistry
    
    init(requestMatcherTypes: [RequestMatcherType]) {
        self.requestMatcherRegistry = RequestMatcherRegistry(types: requestMatcherTypes)
    }
    
    func matchableTrack(request: Request, track: Track) -> Bool {
        return requestMatcherRegistry.matchableRequests(request, anotherRequest: track.request)
    }
}