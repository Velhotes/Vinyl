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
    
    init(vinylName: String, bundle: NSBundle = NSBundle(forClass: Turntable.self)) {
        
        self.bundle = bundle

        guard let plastic: Plastic = loadJSON(bundle, fileName: vinylName) else { fatalError("Vinyl file \"\(vinylName)\" not found 😩") }
        vinyl = Vinyl(plastic: plastic)
    }
    
    override func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        
        return playVinyl(request, completionHandler: completionHandler)
    }

    private func playVinyl(request: NSURLRequest, completionHandler: RequestCompletionHandler) -> NSURLSessionDataTask {
        
        let completion = vinyl.responseSong(forRequest: request)
        completionHandler(completion)
        
        return NSURLSessionDataTask()
    }
}

