//
//  Recorder.swift
//  Vinyl
//
//  Created by Michael Brown on 07/08/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

final class Recorder {
    var wax: Wax
    let recordingPath: String?
    var somethingRecorded = false
    
    init(wax: Wax, recordingPath: String?) {
        self.wax = wax
        self.recordingPath = recordingPath
    }
}

extension Recorder {
    func saveTrack(withRequest request: Request, response: Response) {
        wax.addTrack(Track(request: request, response: response))
        somethingRecorded = true
    }
    
    func saveTrack(withRequest request: Request, urlResponse: NSHTTPURLResponse?, body: NSData? = nil, error: NSError? = nil) {
        let response = Response(urlResponse: urlResponse, body: body, error: error)
        saveTrack(withRequest: request, response: response)
    }
}

extension Recorder {
    
    func persist() throws {
        guard let recordingPath = recordingPath where somethingRecorded else {
            return
        }
        
        let fileManager = NSFileManager.defaultManager()
        guard fileManager.createFileAtPath(recordingPath, contents: nil, attributes: nil) == true,
            let file = NSFileHandle(forWritingAtPath: recordingPath) else {
            return
        }
        
        let jsonWax = wax.tracks.map {
            $0.encodedTrack()
        }
        
        let data = try NSJSONSerialization.dataWithJSONObject(jsonWax, options: .PrettyPrinted)
        file.writeData(data)
        file.synchronizeFile()
        
        print("Vinyl recorded to: \(recordingPath)")
    }
}