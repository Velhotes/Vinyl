//
//  TurntableTests.swift
//  Vinyl
//
//  Created by Rui Peres on 12/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import XCTest
@testable import Vinyl

class TurntableTests: XCTestCase {
    
    func test_Vinyl_single() {
        
        let turntable = Turntable(vinylName: "vinyl_single")
        
        singleCallTest(turntable)
    }
    
    func test_DVR_single() {
        
        let turntable = Turntable(cassetteName: "dvr_single")
        
        singleCallTest(turntable)
    }
    
    func test_Vinyl_multiple() {
        
        let turntable = Turntable(vinylName: "vinyl_multiple")
        
        multipleCallTest(turntable)
    }
    
    func test_DVR_multiple() {
        
        let turntable = Turntable(cassetteName: "dvr_multiple")
        
        multipleCallTest(turntable)
    }
    
    func test_Vinyl_multiple_differentMethods() {
        
        let expectation = self.expectationWithDescription("Expected callback to have the correct URL")
        defer { self.waitForExpectationsWithTimeout(4, handler: nil) }
        
        let turntable = Turntable(
            vinylName: "vinyl_multiple",
            turntableConfiguration: TurntableConfiguration(matchingStrategy: .RequestAttributes(types: [.URL], playTracksUniquely: true)))
        
        let request1 = NSMutableURLRequest(URL: NSURL(string: "http://api.test1.com")!)
        request1.HTTPMethod = "POST"
        
        let request2 = NSMutableURLRequest(URL: NSURL(string: "http://api.test2.com")!)
        request2.HTTPMethod = "POST"
        
        var numberOfCalls = 0
        let checker: (NSData?, NSURLResponse?, NSError?) -> () = { (data, response, anError) in
            
            guard let httpResponse = response as? NSHTTPURLResponse else { fatalError("\(response) should be a NSHTTPURLResponse") }
            
            switch numberOfCalls {
            case 0:
                XCTAssertEqual(httpResponse.URL!.absoluteString, "http://api.test1.com")
                numberOfCalls += 1
            case 1:
                XCTAssertEqual(httpResponse.URL!.absoluteString, "http://api.test2.com")
                expectation.fulfill()
            default: break
            }
        }
        
        turntable.dataTaskWithRequest(request1, completionHandler: checker).resume()
        turntable.dataTaskWithRequest(request2, completionHandler: checker).resume()
    }
    
    func test_Vinyl_multiple_andNotUniquely() {
        
        let expectation = self.expectationWithDescription("Expected callback to have the correct URL")
        defer { self.waitForExpectationsWithTimeout(4, handler: nil) }
        
        let turntable = Turntable(
            vinylName: "vinyl_multiple",
            turntableConfiguration: TurntableConfiguration(matchingStrategy: .RequestAttributes(types: [.URL], playTracksUniquely: false)))
        
        let url1String = "http://api.test1.com"
        let url2String = "http://api.test2.com"
        
        var numberOfCalls = 0
        let checker: (NSData?, NSURLResponse?, NSError?) -> () = { (data, response, anError) in
            
            guard let httpResponse = response as? NSHTTPURLResponse else { fatalError("\(response) should be a NSHTTPURLResponse") }
            
            numberOfCalls += 1
            
            switch numberOfCalls {
            case 1:
                XCTAssertEqual(httpResponse.URL!.absoluteString, url1String)
            case 2...4:
                XCTAssertEqual(httpResponse.URL!.absoluteString, url2String)
                if numberOfCalls == 4 {
                    expectation.fulfill()
                }
            default: break
            }
        }
        
        turntable.dataTaskWithURL(NSURL(string: url1String)!, completionHandler: checker).resume()
        turntable.dataTaskWithURL(NSURL(string: url2String)!, completionHandler: checker).resume()
        turntable.dataTaskWithURL(NSURL(string: url2String)!, completionHandler: checker).resume()
        turntable.dataTaskWithURL(NSURL(string: url2String)!, completionHandler: checker).resume()
    }
    
    
    func test_Vinyl_multiple_uniquely() {
        
        let expectation = self.expectationWithDescription("Expected callback to have the correct URL")
        defer { self.waitForExpectationsWithTimeout(4, handler: nil) }
        
        let turntable = Turntable(
            vinylName: "vinyl_multiple",
            turntableConfiguration: TurntableConfiguration(matchingStrategy: .RequestAttributes(types: [.URL], playTracksUniquely: true)))
        
        let url1String = "http://api.test1.com"
        let url2String = "http://api.test2.com"
        
        let mockedTrackedNotFound = MockedTrackedNotFoundErrorHandler { expectation.fulfill() }
        turntable.errorHandler = mockedTrackedNotFound
        
        var numberOfCalls = 0
        let checker: (NSData?, NSURLResponse?, NSError?) -> () = { (data, response, anError) in
            
            guard let httpResponse = response as? NSHTTPURLResponse else { fatalError("\(response) should be a NSHTTPURLResponse") }
            
            switch numberOfCalls {
            case 0:
                XCTAssertEqual(httpResponse.URL!.absoluteString, url1String)
                numberOfCalls += 1
            case 1:
                XCTAssertEqual(httpResponse.URL!.absoluteString, url2String)
                numberOfCalls += 1
            case 2:
                fatalError("This shouldn't be reached")
            default: break
            }
        }
        
        turntable.dataTaskWithURL(NSURL(string: url1String)!, completionHandler: checker).resume()
        turntable.dataTaskWithURL(NSURL(string: url2String)!, completionHandler: checker).resume()
        turntable.dataTaskWithURL(NSURL(string: url2String)!, completionHandler: checker).resume()
        turntable.dataTaskWithURL(NSURL(string: url2String)!, completionHandler: checker).resume()
        turntable.dataTaskWithURL(NSURL(string: url2String)!, completionHandler: checker).resume()
    }
    
    func test_Vinyl_upload() {
        
        let expectation = self.expectationWithDescription("Expected callback to have the correct response and data")
        defer { self.waitForExpectationsWithTimeout(4, handler: nil) }
        
        let turntable = Turntable(
            vinylName: "vinyl_upload",
            turntableConfiguration: TurntableConfiguration(matchingStrategy: .RequestAttributes(types: [.Method, .URL, .Body], playTracksUniquely: true)))
        
        let urlString = "http://api.test.com"
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try! NSJSONSerialization.dataWithJSONObject(["username": "ziggy", "password": "stardust"], options: [])
        
        turntable.uploadTaskWithRequest(request, fromData: data, completionHandler: { (data, response, error) in
            XCTAssertNil(error)
            
            guard let httpResponse = response as? NSHTTPURLResponse else { fatalError("\(response) should be a NSHTTPURLResponse") }
            
            let body: AnyObject = ["token": "thespidersfrommars"]
            let responseBody = try! NSJSONSerialization.JSONObjectWithData(data!, options: [])
            
            XCTAssertEqual(httpResponse.URL!.absoluteString, urlString)
            XCTAssertEqual(httpResponse.statusCode, 200)
            XCTAssertTrue(responseBody.isEqual(body))
            XCTAssertNotNil(httpResponse.allHeaderFields)
            
            expectation.fulfill()
        }).resume()
    }
    
    func test_playVinyl() {
        
        let turntableConfiguration = TurntableConfiguration()
        let turntable = Turntable(configuration: turntableConfiguration)
        
        let tracks = [
            TrackFactory.createValidTrack(
                NSURL(string: "http://api.test.com")!,
                body: "hello".dataUsingEncoding(NSUTF8StringEncoding),
                headers: [:])
        ]
        
        let vinyl = Vinyl(tracks: tracks)
        turntable.loadVinyl(vinyl)
        singleCallTest(turntable)
    }
    
    func test_playVinylFile() {
        
        let turntableConfiguration = TurntableConfiguration()
        let turntable = Turntable(configuration: turntableConfiguration)
        
        turntable.loadVinyl("vinyl_single")
        singleCallTest(turntable)
    }
    
    func test_playCassetteFile() {
        
        let turntableConfiguration = TurntableConfiguration()
        let turntable = Turntable(configuration: turntableConfiguration)
        
        turntable.loadCassette("dvr_single")
        singleCallTest(turntable)
    }
    
    //MARK: Aux methods
    
    private func singleCallTest(turntable: Turntable) {
        
        let expectation = self.expectationWithDescription("Expected callback to have the correct URL")
        defer { self.waitForExpectationsWithTimeout(4, handler: nil) }
        
        let urlString = "http://api.test.com"
        
        turntable.dataTaskWithURL(NSURL(string: urlString)!) { (data, response, anError) in
            
            XCTAssertNil(anError)
            
            guard let httpResponse = response as? NSHTTPURLResponse else { fatalError("\(response) should be a NSHTTPURLResponse") }
            
            let body = "hello".dataUsingEncoding(NSUTF8StringEncoding)!
            
            XCTAssertEqual(httpResponse.URL!.absoluteString, urlString)
            XCTAssertEqual(httpResponse.statusCode, 200)
            XCTAssertTrue(data!.isEqualToData(body))
            XCTAssertNotNil(httpResponse.allHeaderFields)
            
            expectation.fulfill()
            }.resume()
    }
    
    private func multipleCallTest(turntable: Turntable) {
        
        let expectation = self.expectationWithDescription("Expected callback to have the correct URL")
        defer { self.waitForExpectationsWithTimeout(4, handler: nil) }
        
        let url1String = "http://api.test1.com"
        let url2String = "http://api.test2.com"
        
        var numberOfCalls = 0
        let checker: (NSData?, NSURLResponse?, NSError?) -> () = { (data, response, anError) in
            
            guard let httpResponse = response as? NSHTTPURLResponse else { fatalError("\(response) should be a NSHTTPURLResponse") }
            
            switch numberOfCalls {
            case 0:
                XCTAssertEqual(httpResponse.URL!.absoluteString, url1String)
                numberOfCalls += 1
            case 1:
                XCTAssertEqual(httpResponse.URL!.absoluteString, url2String)
                expectation.fulfill()
            default: break
            }
        }
        
        turntable.dataTaskWithURL(NSURL(string: url1String)!, completionHandler: checker).resume()
        turntable.dataTaskWithURL(NSURL(string: url2String)!, completionHandler: checker).resume()
    }
    
    // MARK: - Track Order strategy
    
    func test_Vinyl_withTrackOrder() {
        
        let expectation = self.expectationWithDescription("All tracks should be placed in order")
        defer { self.waitForExpectationsWithTimeout(4, handler: nil) }
        
        var tracks = [
            TrackFactory.createValidTrack(
                NSURL(string: "http://feelGoodINC.com/request/2")!,
                body: nil,
                headers: [ "header1": "value1" ]),
            TrackFactory.createValidTrack(
                NSURL(string: "http://feelGoodINC.com/request/1")!,
                body: nil,
                headers: [ "header1": "value1", "header2": "value2" ]),
            TrackFactory.createValidTrack(
                NSURL(string: "https://rand.com/")!)
        ]
        
        let request1 = NSMutableURLRequest(URL: NSURL(string: "http://random.com")!)
        request1.HTTPMethod = "POST"
        
        let request2 = NSMutableURLRequest(URL: NSURL(string: "http://random.com/random")!)
        request2.HTTPMethod = "DELETE"
        
        let request3 = NSMutableURLRequest(URL: NSURL(string: "http://random.com/random/another/one")!)
        request2.HTTPMethod = "PUT"
        
        let checker: (NSData?, NSURLResponse?, NSError?) -> () = { (taskData, response, anError) in
            
            guard let httpResponse = response as? NSHTTPURLResponse else {
                fatalError("response should be a `NSHTTPURLResponse`")
            }
            
            if let track = tracks.first {
                
                XCTAssertTrue(httpResponse.statusCode == 200)
                
                if let responseHeaders = httpResponse.allHeaderFields as? HTTPHeaders, let originalHeaders = track.response.urlResponse?.allHeaderFields as? HTTPHeaders {
                    XCTAssertTrue(responseHeaders == originalHeaders)
                }
                
                XCTAssertTrue(httpResponse.URL == track.response.urlResponse?.URL)
                
                tracks.removeAtIndex(tracks.indexOf(track)!)
            }
            
            if tracks.isEmpty {
                expectation.fulfill()
            }
        }
        
        let turntable = Turntable(
            vinyl: Vinyl(tracks: tracks),
            turntableConfiguration: TurntableConfiguration(matchingStrategy: .TrackOrder))
        
        turntable.dataTaskWithRequest(request1, completionHandler: checker).resume()
        turntable.dataTaskWithRequest(request2, completionHandler: checker).resume()
        turntable.dataTaskWithRequest(request3, completionHandler: checker).resume()
    }
    
    //MARK: - Delegate queue
    
    func test_Vinyl_defaultQueue() {
        
        let expectation = self.expectationWithDescription("Expected callback to be called on background thread")
        defer { self.waitForExpectationsWithTimeout(4, handler: nil) }
        
        let turntable = Turntable(vinylName: "vinyl_single")
        
        let urlString = "http://api.test.com"
        
        turntable.dataTaskWithURL(NSURL(string: urlString)!) { (data, response, anError) in
            
            XCTAssertFalse(NSThread.isMainThread())
            expectation.fulfill()
            }.resume()
    }
    
    func test_Vinyl_mainQueue() {
        
        let expectation = self.expectationWithDescription("Expected callback to be called on main thread")
        defer { self.waitForExpectationsWithTimeout(4, handler: nil) }
        
        let turntable = Turntable(vinylName: "vinyl_single", delegateQueue: NSOperationQueue.mainQueue())
        
        let urlString = "http://api.test.com"
        
        turntable.dataTaskWithURL(NSURL(string: urlString)!) { (data, response, anError) in
            
            XCTAssertTrue(NSThread.isMainThread())
            expectation.fulfill()
            }.resume()
    }
    
    func test_Vinyl_Delegate() {
        
        let turntable = Turntable(vinylName: "vinyl_single", delegateQueue: NSOperationQueue.mainQueue())
        XCTAssertNil(turntable.delegate)
    }

    func test_Vinyl_Delegate_Messages() {

        let expectation = self.expectationWithDescription(#function)
        defer { self.waitForExpectationsWithTimeout(4, handler: nil) }

        let delegate = XCTestNSURLSessionDataDelegate(expectation: expectation)
        let turntable = Turntable(vinylName: "vinyl_single", delegate: delegate)
        let urlString = "http://api.test.com"

        let task = turntable.dataTaskWithURL(NSURL(string: urlString)!)
        task.resume()
    }
}
