//
//  Vinyl.swift
//  Vinyl
//
//  Created by Rui Peres on 12/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

final class Vinyl {
    
    private let songs: [Song]
    
    init(plastic: Plastic) {
        songs =  plastic.map(mapToSong)
    }
    
    func hasSong(song: Song) -> Bool  {
        return songs.filter { $0 == song }.count > 0
    }
}

struct Song {
    
    let url: String
    let body: String?
    let HTTPHeaders: [String: AnyObject]
}

extension Song: Equatable {}

func == (lhs: Song, rhs: Song) -> Bool {
    return lhs.url == rhs.url && lhs.body == rhs.body
}

private func mapToSong(trackDictionary: [String: AnyObject]) -> Song {
    
    guard
        let url = trackDictionary["url"] as? String,
        let body = trackDictionary["body"] as? String?,
        let header = trackDictionary["header"] as? [String: AnyObject]
        else { fatalError("key not found 😞 for Song (check url/body/header) \(trackDictionary)")}
    
    return Song(url: url, body: body, HTTPHeaders: header)
}

func encodeBody(bodyData: NSData?, headers: [String: String]) -> String? {
    
    guard
        let body = bodyData,
        let contentType = headers["Content-Type"]
        else { return nil }
    
    switch contentType {
        
    case _ where contentType.hasPrefix("text/"):
        return NSString(data: body, encoding: NSUTF8StringEncoding).map (String.init)
                
    default:
        return body.base64EncodedStringWithOptions([])
    }
}

