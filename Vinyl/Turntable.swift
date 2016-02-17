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
    
    private let player: Player
    
    init(turntableConfiguration: TurntableConfiguration, vinyl: Vinyl) {
        
        let trackMatchers = Turntable.trackMatchersForConfiguration(turntableConfiguration, vinyl: vinyl)
        
        player = Player(vinyl: vinyl, trackMatchers: trackMatchers)
        
        super.init()
    }
    
    convenience init(cassetteName: String, bundle: NSBundle = NSBundle(forClass: Turntable.self), turntableConfiguration: TurntableConfiguration = TurntableConfiguration()) {
        
        guard let cassette: [String: AnyObject] = loadJSON(bundle, fileName: cassetteName) else {
            fatalError("💣 Cassette file \"\(cassetteName)\" not found 😩")
        }
        
        guard let plastic  = cassette["interactions"] as? Plastic else {
            fatalError("💣 We couldn't find the \"interactions\" key in your cassette 😩")
        }
        
        self.init(turntableConfiguration: turntableConfiguration, vinyl: Vinyl(plastic: plastic))
    }
    
    convenience init(vinylName: String, bundle: NSBundle = NSBundle(forClass: Turntable.self), turntableConfiguration: TurntableConfiguration = TurntableConfiguration()) {
        
        guard let plastic: Plastic = loadJSON(bundle, fileName: vinylName) else {
            fatalError("💣 Vinyl file \"\(vinylName)\" not found 😩")
        }
        
        self.init(turntableConfiguration: turntableConfiguration, vinyl: Vinyl(plastic: plastic))
    }
    
    // MARK: - Private methods
    
    private class func trackMatchersForConfiguration(configuration: TurntableConfiguration, vinyl: Vinyl) -> [TrackMatcher] {
        
        var trackMatchers: [TrackMatcher] = [ TypeTrackMatcher(requestMatcherTypes: configuration.requestMatcherTypes) ]
        
        if configuration.playTracksUniquely {
            // NOTE: This should be always the last matcher since we only want to match if the track is still available or not, and that means keeping some state 🙄
            trackMatchers.append(UniqueTrackMatcher(availableTracks: vinyl.tracks))
        }
        
        return trackMatchers
    }
    
    private func playVinyl(request: NSURLRequest, completionHandler: RequestCompletionHandler) -> NSURLSessionDataTask {
        
        let completion = player.playTrack(forRequest: request)
        
        return URLSessionTask(completion: { completionHandler(completion) })
    }
    
    // MARK: - NSURLSession methods
    
    override func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        return playVinyl(request, completionHandler: completionHandler)
    }
}
