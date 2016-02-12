//
//  Album.swift
//  Vinyl
//
//  Created by Rui Peres on 12/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

//import Foundation
//
//struct TrackList {
//    var songs: [Track]!
//    
//    init(disk: Disk) {
//        songs =  disk.map(mapToTrack)
//    }
//}
//
//private func mapToTrack(trackDictionary: [String: AnyObject]) -> Track {
//    
//    guard
//        let url = trackDictionary["url"] as? String,
//        let body = trackDictionary["body"] as? String?,
//        let header = trackDictionary["header"] as? [String: AnyObject]
//        else { fatalError("key not found 😞 for Song (url/body/header) \(trackDictionary)")}
//    
//    return Track(url: url, body: body, HTTPHeaders: header)
//}
//
//struct Track {
//    
//    let url: String
//    let body: String?
//    let HTTPHeaders: [String: AnyObject]
//}
//
//extension Track: Equatable {}
//
//func == (lhs: Track, rhs: Track) -> Bool {
//    return lhs.url == rhs.url && lhs.body == rhs.body
//}