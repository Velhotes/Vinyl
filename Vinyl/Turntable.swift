//
//  Turntable.swift
//  Vinyl
//
//  Created by Rui Peres on 12/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

enum Error: ErrorType {
    
    case TrackNotFound
}

public typealias Plastic = [[String: AnyObject]]
typealias RequestCompletionHandler =  (NSData?, NSURLResponse?, NSError?) -> Void

public final class Turntable: NSURLSession {
    
    var errorHandler: ErrorHandler = DefaultErrorHandler()
    private let turntableConfiguration: TurntableConfiguration
    private let player: Player
    
    public init(turntableConfiguration: TurntableConfiguration, vinyl: Vinyl) {
        
        let trackMatchers = turntableConfiguration.trackMatchersForVinyl(vinyl)
        
        self.player = Player(vinyl: vinyl, trackMatchers: trackMatchers)
        self.turntableConfiguration = turntableConfiguration
        
        super.init()
    }
    
    public convenience init(cassetteName: String, bundle: NSBundle = testingBundle(), turntableConfiguration: TurntableConfiguration = TurntableConfiguration()) {
        
        guard let cassette: [String: AnyObject] = loadJSON(bundle, fileName: cassetteName) else {
            fatalError("💣 Cassette file \"\(cassetteName)\" not found 😩")
        }
        
        guard let plastic  = cassette["interactions"] as? Plastic else {
            fatalError("💣 We couldn't find the \"interactions\" key in your cassette 😩")
        }
        
        self.init(turntableConfiguration: turntableConfiguration, vinyl: Vinyl(plastic: plastic))
    }
    
    public convenience init(vinylName: String, bundle: NSBundle = testingBundle(), turntableConfiguration: TurntableConfiguration = TurntableConfiguration()) {
        
        guard let plastic: Plastic = loadJSON(bundle, fileName: vinylName) else {
            fatalError("💣 Vinyl file \"\(vinylName)\" not found 😩")
        }
        
        self.init(turntableConfiguration: turntableConfiguration, vinyl: Vinyl(plastic: plastic))
    }
    
    // MARK: - Private methods
    
    private func playVinyl(request: NSURLRequest, completionHandler: RequestCompletionHandler) throws -> NSURLSessionDataTask {
        
        let completion = try player.playTrack(forRequest: request)
        
        return URLSessionTask(completion: { completionHandler(completion) })
    }
    
    // MARK: - NSURLSession methods
    
    public override func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        
        do {
            return try playVinyl(request, completionHandler: completionHandler)
        }
        catch Error.TrackNotFound {
            errorHandler.handleTrackNotFound(request, playTracksUniquely: turntableConfiguration.playTracksUniquely)
        }
        catch {
            errorHandler.handleUnknownError()
        }
        
        return URLSessionTask(completion: {})
    }
    
    
    public override func invalidateAndCancel() {
        // We won't do anything for
    }
}
