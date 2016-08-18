//
//  TurntableConfiguration.swift
//  Vinyl
//
//  Created by David Rodrigues on 17/02/16.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

public enum MatchingStrategy {
    case RequestAttributes(types: [RequestMatcherType], playTracksUniquely: Bool)
    case TrackOrder
}

public enum RecordingMode {
    case None
    case MissingTracks(recordingPath: String?)
    case MissingVinyl(recordingPath: String?)
}

public struct TurntableConfiguration {
    
    public let matchingStrategy: MatchingStrategy
    public let recordingMode: RecordingMode
    
    var playTracksUniquely: Bool {
        get {
            switch matchingStrategy {
            case .RequestAttributes(_, let playTracksUniquely): return playTracksUniquely
            case .TrackOrder: return true
            }
        }
    }

    var recodingEnabled: Bool {
        get {
            switch recordingMode {
            case .None:
                return false
            default:
                return true
            }
        }
    }
    
    var recordingPath: String? {
        get {
            switch recordingMode {
            case .MissingVinyl(let path):
                return path
            case .MissingTracks(let path):
                return path
            default:
                return .None
            }
        }
    }
    
    public init(matchingStrategy: MatchingStrategy = .RequestAttributes(types: [.Method, .URL], playTracksUniquely: true), recordingMode: RecordingMode = .MissingVinyl(recordingPath: nil)) {
        self.matchingStrategy = matchingStrategy
        self.recordingMode = recordingMode
    }
    
    func trackMatchersForVinyl(vinyl: Vinyl) -> [TrackMatcher] {
        
        switch matchingStrategy {
            
        case .RequestAttributes(let types, let playTracksUniquely):
            
            var trackMatchers: [TrackMatcher] = [ TypeTrackMatcher(requestMatcherTypes: types) ]
            
            if playTracksUniquely {
                // NOTE: This should be always the last matcher since we only want to match if the track is still available or not, and that means keeping some state 🙄
                trackMatchers.append(UniqueTrackMatcher(availableTracks: vinyl.tracks))
            }
            
            return trackMatchers
            
        case .TrackOrder:
            return [ UniqueTrackMatcher(availableTracks: vinyl.tracks) ]
        }
    }
}
