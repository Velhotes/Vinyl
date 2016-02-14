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
    
    init(plastic: Plastic) {
        tracks = plastic.map(Track.init)
    }
    
    func responseTrack(forRequest request: NSURLRequest) -> (NSData?, NSURLResponse?, NSError?)  {
        
        // TODO: Right now we are just comparing the Request, in the future we should compare the body and HTTPMethod
        guard
            let track = (tracks.filter { $0.request.URL == request.URL }.first)
        else {
            fatalError("No recorded 🎶 with the Request's url \(request.URL?.absoluteURL) was found 😩")
        }
        
        return (track.response.body, track.response.urlResponse, nil)
    }
}
