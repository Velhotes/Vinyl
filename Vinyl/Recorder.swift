//
//  Recorder.swift
//  Vinyl
//
//  Created by Michael Brown on 07/08/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

struct Recorder {
    
    var wax: Wax
    let recordingPath: String?

    mutating func saveTrack(withRequest request: Request, response: Response) {
        wax.addTrack(Track(request: request, response: response))
    }
    
    mutating func saveTrack(withRequest request: Request, urlResponse: NSHTTPURLResponse?, body: NSData? = nil, error: NSError? = nil) {
        let response = Response(urlResponse: urlResponse, body: body, error: error)
        saveTrack(withRequest: request, response: response)
    }
}
