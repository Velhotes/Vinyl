//
//  URLSessionUploadTask.swift
//  Vinyl
//
//  Created by Fabio Ritrovato on 01/03/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

public final class URLSessionUploadTask: NSURLSessionUploadTask {
    
    private let completion: Void -> Void
    
    init(completion: Void -> Void) {
        self.completion = completion
    }
    
    public override func resume() {
        completion()
    }
    
    public override func suspend() {
        // We won't do anything here
    }
    
    public override func cancel() {
        // We won't do anything here
    }
}
