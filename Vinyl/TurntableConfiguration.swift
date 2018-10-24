//
//  TurntableConfiguration.swift
//  Vinyl
//
//  Created by David Rodrigues on 17/02/16.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

public enum MatchingStrategy {
    case requestAttributes(types: [RequestMatcherType], playTracksUniquely: Bool)
    case trackOrder
}

public enum RecordingMode {
    case none
    case missingTracks(recordingPath: String?)
    case missingVinyl(recordingPath: String?)
}

public enum RecordingStrategy {
    case always
    case nonEmpty
}

public struct TurntableConfiguration {
    
    public let matchingStrategy: MatchingStrategy
    public let recordingMode: RecordingMode
    public let recordingStrategy: RecordingStrategy

    var playTracksUniquely: Bool {
        get {
            switch matchingStrategy {
            case .requestAttributes(_, let playTracksUniquely): return playTracksUniquely
            case .trackOrder: return true
            }
        }
    }

    var recodingEnabled: Bool {
        get {
            switch recordingMode {
            case .none:
                return false
            default:
                return true
            }
        }
    }
    
    var recordingPath: String? {
        get {
            switch recordingMode {
            case .missingVinyl(let path):
                return path
            case .missingTracks(let path):
                return path
            default:
                return .none
            }
        }
    }
    
    public init(
        matchingStrategy: MatchingStrategy = .requestAttributes(types: [.method, .url], playTracksUniquely: true),
        recordingMode: RecordingMode = .missingVinyl(recordingPath: nil),
        recordingStrategy: RecordingStrategy = .nonEmpty
    ) {
        self.matchingStrategy = matchingStrategy
        self.recordingStrategy = recordingStrategy
        self.recordingMode = recordingMode
    }
    
    func trackMatchers(for vinyl: Vinyl) -> [TrackMatcher] {
        
        switch matchingStrategy {
            
        case .requestAttributes(let types, let playTracksUniquely):
            
            var trackMatchers: [TrackMatcher] = [ TypeTrackMatcher(requestMatcherTypes: types) ]
            
            if playTracksUniquely {
                // NOTE: This should be always the last matcher since we only want to match if the track is still available or not, and that means keeping some state 🙄
                trackMatchers.append(UniqueTrackMatcher(availableTracks: vinyl.tracks))
            }
            
            return trackMatchers
            
        case .trackOrder:
            return [ UniqueTrackMatcher(availableTracks: vinyl.tracks) ]
        }
    }
}
