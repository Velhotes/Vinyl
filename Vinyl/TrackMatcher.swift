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

struct DefaultTrackMatcher: TrackMatcher {
    
    let requestMatcherRegistry: RequestMatcherRegistry
    
    init(requestMatcherTypes: [RequestMatcherType]) {
        self.requestMatcherRegistry = RequestMatcherRegistry(types: requestMatcherTypes)
    }
    
    func matchableTrack(request: Request, track: Track) -> Bool {
        return requestMatcherRegistry.matchableRequests(request, anotherRequest: track.request)
    }
}