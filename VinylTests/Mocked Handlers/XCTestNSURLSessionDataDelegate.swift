//
//  XCTestNSURLSessionDataDelegate.swift
//  Vinyl
//
//  Created by Ryan Lovelett on 6/15/16.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import XCTest

final class XCTestNSURLSessionDataDelegate : NSObject, NSURLSessionDataDelegate {
    private let expectation: XCTestExpectation
    private var sessionID: Int?

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
        super.init()
    }

    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        self.sessionID = dataTask.taskIdentifier
        XCTAssertNotNil(dataTask.originalRequest)
        XCTAssertNotNil(dataTask.currentRequest)
    }

    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        XCTAssertEqual(self.sessionID, dataTask.taskIdentifier)
        XCTAssertNotNil(dataTask.originalRequest)
        XCTAssertNotNil(dataTask.currentRequest)
    }

    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        XCTAssertEqual(self.sessionID, task.taskIdentifier)
        XCTAssertEqual(task.state, NSURLSessionTaskState.Completed)
        XCTAssertNotNil(task.originalRequest)
        XCTAssertNotNil(task.currentRequest)
        expectation.fulfill()
    }
}