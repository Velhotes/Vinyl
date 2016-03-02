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
    private var player: Player?
    private let operationQueue: NSOperationQueue
    
    public init(configuration: TurntableConfiguration, delegateQueue: NSOperationQueue? = nil) {
        
        self.turntableConfiguration = configuration
        if let delegateQueue = delegateQueue {
            self.operationQueue = delegateQueue
        } else {
            self.operationQueue = NSOperationQueue()
            self.operationQueue.maxConcurrentOperationCount = 1
        }
        super.init()
    }
    
    public convenience init(vinyl: Vinyl, turntableConfiguration: TurntableConfiguration, delegateQueue: NSOperationQueue? = nil) {
        
        self.init(configuration: turntableConfiguration, delegateQueue: delegateQueue)
        self.player = Turntable.createPlayer(vinyl, configuration: turntableConfiguration)
    }
    
    public convenience init(cassetteName: String, bundle: NSBundle = testingBundle(), turntableConfiguration: TurntableConfiguration = TurntableConfiguration(), delegateQueue: NSOperationQueue? = nil) {
        
        let vinyl = Vinyl(plastic: Turntable.createCassettePlastic(cassetteName, bundle: bundle))
        self.init(vinyl: vinyl, turntableConfiguration: turntableConfiguration, delegateQueue: delegateQueue)
    }
    
    public convenience init(vinylName: String, bundle: NSBundle = testingBundle(), turntableConfiguration: TurntableConfiguration = TurntableConfiguration(), delegateQueue: NSOperationQueue? = nil) {
        
        let plastic = Turntable.createVinylPlastic(vinylName, bundle: bundle)
        self.init(vinyl: Vinyl(plastic: plastic), turntableConfiguration: turntableConfiguration, delegateQueue: delegateQueue)
    }
    
    // MARK: - Private methods
    
    private func playVinyl(request: NSURLRequest, completionHandler: RequestCompletionHandler) throws -> NSURLSessionDataTask {
        
        guard let player = self.player else {
            fatalError("Did you forget to load the Vinyl? 🎶")
        }
        
        let completion = try player.playTrack(forRequest: request)
        
        return URLSessionTask(completion: { self.operationQueue.addOperationWithBlock { completionHandler(completion) } })
    }
    
    private func playVinyl(request: NSURLRequest, fromData bodyData: NSData?, completionHandler: RequestCompletionHandler) throws -> NSURLSessionUploadTask {
        
        guard let player = self.player else {
            fatalError("Did you forget to load the Vinyl? 🎶")
        }
        
        guard let uploadRequest = request.mutableCopy() as? NSMutableURLRequest else {
            fatalError("💥")
        }
        uploadRequest.HTTPBody = bodyData
        let completion = try player.playTrack(forRequest: uploadRequest)
        
        return URLSessionUploadTask(completion: { self.operationQueue.addOperationWithBlock { completionHandler(completion) } })
    }

    // MARK: - NSURLSession methods
    
    public override func dataTaskWithURL(url: NSURL, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        let request = NSURLRequest(URL: url)
        return dataTaskWithRequest(request, completionHandler: completionHandler)
    }
    
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
    
    public override func uploadTaskWithRequest(request: NSURLRequest, fromData bodyData: NSData?, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionUploadTask {
        
        do {
            return try playVinyl(request, fromData: bodyData, completionHandler: completionHandler)
        }
        catch Error.TrackNotFound {
            errorHandler.handleTrackNotFound(request, playTracksUniquely: turntableConfiguration.playTracksUniquely)
        }
        catch {
            errorHandler.handleUnknownError()
        }
        
        return URLSessionUploadTask(completion: {})
    }
    
    public override func invalidateAndCancel() {
        // We won't do anything for
    }
}

extension Turntable {
    
    public func loadVinyl(vinylName: String,  bundle: NSBundle = testingBundle()) {
        
        let vinyl = Vinyl(plastic: Turntable.createVinylPlastic(vinylName, bundle: bundle))
        self.player = Turntable.createPlayer(vinyl, configuration: turntableConfiguration)
    }
    
    public func loadCassette(cassetteName: String,  bundle: NSBundle = testingBundle()) {
        
        let vinyl = Vinyl(plastic: Turntable.createCassettePlastic(cassetteName, bundle: bundle))
        self.player = Turntable.createPlayer(vinyl, configuration: turntableConfiguration)
    }
    
    public func loadVinyl(vinyl: Vinyl) {
        self.player = Turntable.createPlayer(vinyl, configuration: turntableConfiguration)
    }
}

extension Turntable {
    
    private static func createPlayer(vinyl: Vinyl, configuration: TurntableConfiguration) -> Player {
        
        let trackMatchers = configuration.trackMatchersForVinyl(vinyl)
        return Player(vinyl: vinyl, trackMatchers: trackMatchers)
    }
    
    private static func createCassettePlastic(cassetteName: String, bundle: NSBundle) -> Plastic {
        
        guard let cassette: [String: AnyObject] = loadJSON(bundle, fileName: cassetteName) else {
            fatalError("💣 Cassette file \"\(cassetteName)\" not found 😩")
        }
        
        guard let plastic = cassette["interactions"] as? Plastic else {
            fatalError("💣 We couldn't find the \"interactions\" key in your cassette 😩")
        }
        
        return plastic
    }
    
    private static func createVinylPlastic(vinylName: String, bundle: NSBundle) -> Plastic {
        
        guard let plastic: Plastic = loadJSON(bundle, fileName: vinylName) else {
            fatalError("💣 Vinyl file \"\(vinylName)\" not found 😩")
        }
        
        return plastic
    }
}
