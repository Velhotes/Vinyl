//
//  URLSessionDataTask.swift
//  Vinyl
//
//  Created by Rui Peres on 16/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

private func generate() -> AnyGenerator<Int> {
    var current = 0
    return AnyGenerator<Int>(body: {
        current = current + 1
        return current
    })
}

private let sharedSequence: AnyGenerator<Int> = generate()

typealias URLSessionDataTaskCallback = (NSData?, NSURLResponse?, NSError?) -> Void

public final class URLSessionDataTask: NSURLSessionDataTask {

    private let session: Turntable
    private let request: NSURLRequest
    private let delegate: NSURLSessionDataDelegate?
    private let callback: URLSessionDataTaskCallback?

    init(session: Turntable, request: NSURLRequest, callback: URLSessionDataTaskCallback? = nil) {
        self.session = session
        self.request = request
        self.delegate = session.delegate as? NSURLSessionDataDelegate
        self.callback = callback
    }

    // MARK: - Controlling the Task State

    public override func cancel() {
        // We won't do anything here
    }

    public override func resume() {
        _state = .Running
        var data: NSData?
        do {
            let playedTrack = try self.session.player?.playTrack(forRequest: self.request)
            data = playedTrack?.data
            self._response = playedTrack?.response
            self._error = playedTrack?.error

            // Delegate Message #1
            if let response = response {
                self.session.operationQueue.addOperationWithBlock {
                    self.delegate?.URLSession?(self.session, dataTask: self, didReceiveResponse: response) { (_) in }
                }
            }

            // Delegate Message #2
            if let data = data {
                self.session.operationQueue.addOperationWithBlock {
                    self.delegate?.URLSession?(self.session, dataTask: self, didReceiveData: data)
                }
            }

            // Delegate Message #3
            self.session.operationQueue.addOperationWithBlock {
                self.delegate?.URLSession?(self.session, task: self, didCompleteWithError: self.error)
                self.callback?(data, self.response, self.error)
            }
        } catch Error.TrackNotFound {
            self.session.errorHandler.handleTrackNotFound(self.request, playTracksUniquely: self.session.turntableConfiguration.playTracksUniquely)
        } catch {
            self.session.errorHandler.handleUnknownError()
        }
        _state = .Completed
    }

    public override func suspend() {
        // We won't do anything here
    }

    private var _state: NSURLSessionTaskState = .Suspended
    override public var state: NSURLSessionTaskState {
        return _state
    }

    // MARK: - Obtaining General Task Information

    override public var currentRequest: NSURLRequest? {
        return request
    }

    override public var originalRequest: NSURLRequest? {
        return request
    }

    private var _response: NSURLResponse? = nil
    override public var response: NSURLResponse? {
        return _response
    }

    private let _id: Int = sharedSequence.next()!
    override public var taskIdentifier: Int {
        return _id
    }

    private var _error: NSError? = nil
    override public var error: NSError? {
        return _error
    }
}
