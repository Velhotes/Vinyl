//
//  Wax.swift
//  Vinyl
//
//  Created by Michael Brown on 07/08/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

struct Wax {
    
    var tracks: [Track] = []
    
    init(vinyl: Vinyl) {
        tracks.append(contentsOf: vinyl.tracks)
    }
    
    init(tracks: [Track]) {
        self.tracks.append(contentsOf: tracks)
    }
    
    mutating func addTrack(_ track: Track) {
        tracks.append(track)
    }
}
