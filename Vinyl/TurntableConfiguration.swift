//
//  TurntableConfiguration.swift
//  Vinyl
//
//  Created by David Rodrigues on 17/02/16.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

struct TurntableConfiguration {
    
    let requestMatcherTypes: [RequestMatcherType]
    
    let playTracksUniquely: Bool
    
    init(requestMatcherTypes: [RequestMatcherType] = [.Method, .URL], playTracksUniquely: Bool = true) {
        self.requestMatcherTypes = requestMatcherTypes
        self.playTracksUniquely = playTracksUniquely
    }
}