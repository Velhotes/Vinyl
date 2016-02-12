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
    
    func responseSong(forRequest request: NSURLRequest) -> (NSData?, NSURLResponse?, NSError?)  {
        
        // TODO: Right now we are just comparing the Request, in the future we should compare the body and HTTPMethod
        guard let song = (songs.filter { $0.url == request.URL! }.first)
            else { fatalError("No recorded 🎶 with the Request's url \(request.URL?.absoluteURL) was found 😩")}
        
        let response = NSHTTPURLResponse(URL: song.url, statusCode: song.statusCode, HTTPVersion: nil, headerFields: song.HTTPHeaders)
        let data = decodeBody(song.body, headers: song.HTTPHeaders)
        
        return (data, response, nil)
    }
}

struct Song {
    
    let url: NSURL
    let body: AnyObject?
    let statusCode: Int
    let HTTPHeaders: [String: String]
}

private func mapToSong(trackDictionary: [String: AnyObject]) -> Song {
    
    guard
        let url = trackDictionary["url"] as? String,
        let statusCode = trackDictionary["statusCode"] as? Int,
        let header = trackDictionary["header"] as? [String: String]
        
        else { fatalError("key not found 😞 for Song (check url/body/statusCode/header) \(trackDictionary)")}
    
    let body = trackDictionary["body"]

    return Song(url: NSURL(string: url)!, body: body, statusCode: statusCode, HTTPHeaders: header)
}
