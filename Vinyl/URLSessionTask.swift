//
//  URLSessionTask.swift
//  Vinyl
//
//  Created by Rui Peres on 16/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

final class URLSessionTask: NSURLSessionDataTask {
    
    private let completion: Void -> Void
    
    init(completion: Void -> Void) {
        self.completion = completion
    }
    
    override func resume() {
        completion()
    }
    
    override func cancel() {
        // We won't do anything here
    }
}