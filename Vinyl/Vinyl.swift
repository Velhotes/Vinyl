//
//  Vinyl.swift
//  Vinyl
//
//  Created by Rui Peres on 12/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

public struct Vinyl {
    
    let tracks: [Track]
    
    public init(plastic: Plastic) {
        tracks = plastic.map(Track.init)
    }
    
    public init(tracks: [Track]) {
        
        self.tracks = tracks
    }
}
