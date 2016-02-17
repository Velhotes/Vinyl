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
    
    static func createBadVinyl(url: NSURL, statusCode: Int) -> Vinyl {
        
        let response = HTTPURLResponse(URL: url, MIMEType: nil, expectedContentLength: 0, textEncodingName: nil)
        response.statusCode = statusCode
        
        let track = Track(response: Response(urlResponse: response))
        return Vinyl(tracks: [track])
    }
}