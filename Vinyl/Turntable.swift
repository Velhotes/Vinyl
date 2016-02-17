//
//  Turntable.swift
//  Vinyl
//
//  Created by Rui Peres on 12/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

typealias Plastic = [[String: AnyObject]]

typealias RequestCompletionHandler =  (NSData?, NSURLResponse?, NSError?) -> Void

final class Turntable: NSURLSession {
    
    private let bundle: NSBundle?
    private let player: Player
    
    var playTracksInSequence = false
    
    init(vinyl: Vinyl, requestMatcherTypes: [RequestMatcherType] = [.Method, .URL]) {
        
        self.bundle = nil
        self.player = Player(vinyl: vinyl, trackMatcher: DefaultTrackMatcher(requestMatcherTypes: requestMatcherTypes))
        
        super.init()
    }
    
    init(vinylName: String, bundle: NSBundle = NSBundle(forClass: Turntable.self), requestMatcherTypes: [RequestMatcherType] = [.Method, .URL]) {
        
        guard let plastic: Plastic = loadJSON(bundle, fileName: vinylName) else {
            fatalError("💣 Vinyl file \"\(vinylName)\" not found 😩")
        }
        
        self.bundle = bundle
        self.player = Player(vinyl: Vinyl(plastic: plastic), trackMatcher: DefaultTrackMatcher(requestMatcherTypes: requestMatcherTypes))
        
        super.init()
    }
    
    override func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        return playVinyl(request, completionHandler: completionHandler)
    }

    private func playVinyl(request: NSURLRequest, completionHandler: RequestCompletionHandler) -> NSURLSessionDataTask {
        
        let completion = player.playTrack(forRequest: request)
        
        return URLSessionTask(completion: { completionHandler(completion) })
    }
}
