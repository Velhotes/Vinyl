//
//  MockedTrackedNotFoundErrorHandler.swift
//  Vinyl
//
//  Created by Rui Peres on 18/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation
@testable import Vinyl

final class MockedTrackedNotFoundErrorHandler: ErrorHandler {
    
    private lazy var __completeOnce: () = { () -> Void in
            self.completion()
        }()
    
    fileprivate let completion: (Void) -> Void
    
    init (completion: @escaping (Void) -> Void) {
        self.completion = completion
    }
    
    fileprivate var token: Int = 0
    func handleTrackNotFound(_ request: Request, playTracksUniquely: Bool) {
        
        // If this gets called multiple times and has an "expectation.fullfill()" it will crash
        // So we make sure it will only be called once.
        // It also makes sense, since in the DefaultErrorHandler this would call fatal_error (which is only called once)
        _ = self.__completeOnce
    }
    
    func handleUnknownError() {
        fatalError("This shouldn't be called")
    }
}
