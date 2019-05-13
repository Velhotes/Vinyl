//
//  ErrorHandler.swift
//  Vinyl
//
//  Created by Rui Peres on 18/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

public protocol ErrorHandler {
    func handleTrackNotFound(_ request: Request, playTracksUniquely: Bool)
    func handleUnknownError()
}

public struct DefaultErrorHandler: ErrorHandler {

    public init() {}

    public func handleTrackNotFound(_ request: Request, playTracksUniquely: Bool) {
     
        if playTracksUniquely {
            fatalError("💥 No 🎶 recorded and matchable with request: \n\(request.debugDescription)\n\nThis might be happening because you are trying to consume the same request multiple times 😩\n")
        }
        else {
            fatalError("💥 No 🎶 recorded and matchable with request: \n\(request.debugDescription)\n")
        }
    }
    
    public func handleUnknownError() {
        fatalError("💥")
    }
}
