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
    internal let turntableConfiguration: TurntableConfiguration
    internal var player: Player?
    internal let operationQueue: NSOperationQueue
    private let _delegate: NSURLSessionDelegate?
    
    public init(configuration: TurntableConfiguration, delegate: NSURLSessionDelegate? = nil, delegateQueue: NSOperationQueue? = nil) {
        _delegate = delegate
        turntableConfiguration = configuration
        if let delegateQueue = delegateQueue {
            operationQueue = delegateQueue
        } else {
            operationQueue = NSOperationQueue()
            operationQueue.maxConcurrentOperationCount = 1
        }
        super.init()
    }
    
    public convenience init(vinyl: Vinyl, turntableConfiguration: TurntableConfiguration = TurntableConfiguration(), delegate: NSURLSessionDelegate? = nil, delegateQueue: NSOperationQueue? = nil) {
        
        self.init(configuration: turntableConfiguration, delegate: delegate, delegateQueue: delegateQueue)
        player = Turntable.createPlayer(vinyl, configuration: turntableConfiguration)
    }
    
    public convenience init(cassetteName: String, bundle: NSBundle = testingBundle(), turntableConfiguration: TurntableConfiguration = TurntableConfiguration(), delegate: NSURLSessionDelegate? = nil, delegateQueue: NSOperationQueue? = nil) {
        
        let vinyl = Vinyl(plastic: Turntable.createCassettePlastic(cassetteName, bundle: bundle))
        self.init(vinyl: vinyl, turntableConfiguration: turntableConfiguration, delegate: delegate, delegateQueue: delegateQueue)
    }
    
    public convenience init(vinylName: String, bundle: NSBundle = testingBundle(), turntableConfiguration: TurntableConfiguration = TurntableConfiguration(), delegate: NSURLSessionDelegate? = nil, delegateQueue: NSOperationQueue? = nil) {
        
        let plastic = Turntable.createVinylPlastic(vinylName, bundle: bundle)
        self.init(vinyl: Vinyl(plastic: plastic), turntableConfiguration: turntableConfiguration, delegate: delegate, delegateQueue: delegateQueue)
    }
    
    // MARK: - Private methods

    private func playVinyl(request request: NSURLRequest, fromData bodyData: NSData? = nil, completionHandler: RequestCompletionHandler) throws -> URLSessionUploadTask {

        guard let player = player else {
            fatalError("Did you forget to load the Vinyl? 🎶")
        }

        let completion = try player.playTrack(forRequest: transformRequest(request, bodyData: bodyData))

        return URLSessionUploadTask {
            self.operationQueue.addOperationWithBlock {
                completionHandler(completion.data, completion.response, completion.error)
            }
        }
    }

    private func transformRequest(request: NSURLRequest, bodyData: NSData? = nil) -> NSURLRequest {
        guard let bodyData = bodyData else {
            return request
        }

        guard let mutableRequest = request.mutableCopy() as? NSMutableURLRequest else {
            fatalError("💥 Houston, we have a problem 🚀")
        }

        mutableRequest.HTTPBody = bodyData

        return mutableRequest
    }

    public override var delegate: NSURLSessionDelegate? {
        return _delegate
    }
}

// MARK: - NSURLSession methods

extension Turntable {

    public override func dataTaskWithURL(url: NSURL) -> NSURLSessionDataTask {
        let request = NSURLRequest(URL: url)
        return dataTaskWithRequest(request)
    }
    
    public override func dataTaskWithURL(url: NSURL, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        let request = NSURLRequest(URL: url)
        return dataTaskWithRequest(request, completionHandler: completionHandler)
    }

    public override func dataTaskWithRequest(request: NSURLRequest) -> NSURLSessionDataTask {
        return URLSessionDataTask(session: self, request: request)
    }
    
    public override func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        return URLSessionDataTask(session: self, request: request, callback: completionHandler)
    }
    
    public override func uploadTaskWithRequest(request: NSURLRequest, fromData bodyData: NSData?, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionUploadTask {
        
        do {
            return try playVinyl(request: request, fromData: bodyData, completionHandler: completionHandler) as URLSessionUploadTask
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

// MARK: - Loading Methods

extension Turntable {
    
    public func loadVinyl(vinylName: String,  bundle: NSBundle = testingBundle()) {
        
        let vinyl = Vinyl(plastic: Turntable.createVinylPlastic(vinylName, bundle: bundle))
        player = Turntable.createPlayer(vinyl, configuration: turntableConfiguration)
    }
    
    public func loadCassette(cassetteName: String,  bundle: NSBundle = testingBundle()) {
        
        let vinyl = Vinyl(plastic: Turntable.createCassettePlastic(cassetteName, bundle: bundle))
        player = Turntable.createPlayer(vinyl, configuration: turntableConfiguration)
    }
    
    public func loadVinyl(vinyl: Vinyl) {
        player = Turntable.createPlayer(vinyl, configuration: turntableConfiguration)
    }
}

// MARK: - Bootstrap methods

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
