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
    
    private let bundle: NSBundle
    private let vinyl: Vinyl
    private let player: Player
    
    var playTracksInSequence = false
    
    init(vinylName: String, bundle: NSBundle = NSBundle(forClass: Turntable.self), requestMatcherTypes: [RequestMatcherType] = [.Method, .URL]) {
        
        guard let plastic: Plastic = loadJSON(bundle, fileName: vinylName) else {
            fatalError("💣 Vinyl file \"\(vinylName)\" not found 😩")
        }
        
        self.bundle = bundle
        self.vinyl = Vinyl(plastic: plastic)
        self.player = Player(vinyl: vinyl, trackMatcher: DefaultTrackMatcher(requestMatcherTypes: requestMatcherTypes))
        super.init()
    }
    
    override func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        return playVinyl(request, completionHandler: completionHandler)
    }

    private func playVinyl(request: NSURLRequest, completionHandler: RequestCompletionHandler) -> NSURLSessionDataTask {
        
        let completion = player.playTrack(forRequest: request)
        
        completionHandler(completion)
        
        return NSURLSessionDataTask()
    }
}
