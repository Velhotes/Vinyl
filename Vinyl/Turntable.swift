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
    static var configuration = TurntableConfiguration()

    private let player: Player
    
    public init(vinyl: Vinyl, turntableConfiguration: TurntableConfiguration? = nil) {
        
        let configuration = turntableConfiguration ?? Turntable.configuration
        let trackMatchers = configuration.trackMatchersForVinyl(vinyl)
        
        self.player = Player(vinyl: vinyl, trackMatchers: trackMatchers)
        Turntable.configuration = configuration
        
        super.init()
    }
    
    public convenience init(cassetteName: String, bundle: NSBundle = testingBundle(), turntableConfiguration: TurntableConfiguration? = nil) {
        
        guard let cassette: [String: AnyObject] = loadJSON(bundle, fileName: cassetteName) else {
            fatalError("💣 Cassette file \"\(cassetteName)\" not found 😩")
        }
        
        guard let plastic  = cassette["interactions"] as? Plastic else {
            fatalError("💣 We couldn't find the \"interactions\" key in your cassette 😩")
        }
        
        self.init(vinyl: Vinyl(plastic: plastic), turntableConfiguration: turntableConfiguration)
    }
    
    public convenience init(vinylName: String, bundle: NSBundle = testingBundle(), turntableConfiguration: TurntableConfiguration = TurntableConfiguration()) {
        
        guard let plastic: Plastic = loadJSON(bundle, fileName: vinylName) else {
            fatalError("💣 Vinyl file \"\(vinylName)\" not found 😩")
        }
        
        self.init(vinyl: Vinyl(plastic: plastic), turntableConfiguration: turntableConfiguration)
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
            errorHandler.handleTrackNotFound(request, playTracksUniquely: Turntable.configuration.playTracksUniquely)
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
