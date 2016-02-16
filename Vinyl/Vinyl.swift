//
//  Vinyl.swift
//  Vinyl
//
//  Created by Rui Peres on 12/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

final class Vinyl {
    
    let tracks: [Track]
    
    init(plastic: Plastic) {
        tracks = plastic.map(Track.init)
    }
}
