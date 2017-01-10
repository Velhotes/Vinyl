//
//  TrackMatcher.swift
//  Vinyl
//
//  Created by David Rodrigues on 16/02/16.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

protocol TrackMatcher {
    func matchable(track: Track, for request: Request) -> Bool
}

// We cannot use a struct, otherwise we need to mark `-matchableTrack` as mutating and that breaks protocol conformance (rdar://21966810)
final class UniqueTrackMatcher: TrackMatcher {

    fileprivate var availableTracks: [Track]
    
    init(availableTracks: [Track]) {
        self.availableTracks = availableTracks
    }
    
    func matchable(track: Track, for request: Request) -> Bool {
        
        if let index = availableTracks.index(of: track) {
            availableTracks.remove(at: index)
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
    
    func matchable(track: Track, for request: Request) -> Bool {
        return requestMatcherRegistry.matchableRequests(request: request, with: track.request)
    }
}
