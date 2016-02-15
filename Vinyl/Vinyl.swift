//
//  Vinyl.swift
//  Vinyl
//
//  Created by Rui Peres on 12/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

final class Vinyl {
    
    private let tracks: [Track]
    private let requestMatcherRegistry: RequestMatcherRegistry
    
    init(plastic: Plastic, registry: RequestMatcherRegistry) {
        tracks = plastic.map(Track.init)
        requestMatcherRegistry = registry
    }
    
    func responseTrack(forRequest request: NSURLRequest) -> (NSData?, NSURLResponse?, NSError?)  {
        
        for track in tracks {
            if requestMatcherRegistry.matchableRequests(request, anotherRequest: track.request) {
                // TODO: We should support a `NSError` in the future
                return (track.response.body, track.response.urlResponse, nil)
            }
        }
        
        fatalError("💥 No 🎶 recorded and matchable with request: \(request.debugDescription) 😩")
    }
}
