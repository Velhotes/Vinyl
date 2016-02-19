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
        
        let turnatable = Turntable(vinylName: "vinyl_single")
        
        singleCallTest(turnatable)
    }
    
    func test_DVR_single() {

        let turnatable = Turntable(cassetteName: "dvr_single")
        
        singleCallTest(turnatable)
    }
    
    func test_Vinyl_multiple() {
        
        let turnatable = Turntable(vinylName: "vinyl_multiple")
        
        multipleCallTest(turnatable)
    }
    
    func test_DVR_multiple() {
        
        let turnatable = Turntable(cassetteName: "dvr_multiple")
        
        multipleCallTest(turnatable)
    }
    
    func test_Vinyl_multiple_differentMethods() {
        
        let expectation = self.expectationWithDescription("Expected callback to have the correct URL")
        defer { self.waitForExpectationsWithTimeout(4, handler: nil) }
        
        let turnatable = Turntable(
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
        
        turnatable.dataTaskWithRequest(request1, completionHandler: checker).resume()
        turnatable.dataTaskWithRequest(request2, completionHandler: checker).resume()
    }
    
    func test_Vinyl_multiple_andNotUniquely() {
        
        let expectation = self.expectationWithDescription("Expected callback to have the correct URL")
        defer { self.waitForExpectationsWithTimeout(4, handler: nil) }
        
        let turnatable = Turntable(
            vinylName: "vinyl_multiple",
            turntableConfiguration: TurntableConfiguration(matchingStrategy: .RequestAttributes(types: [.URL], playTracksUniquely: false)))
        
        let request1 = NSMutableURLRequest(URL: NSURL(string: "http://api.test1.com")!)
        let request2 = NSMutableURLRequest(URL: NSURL(string: "http://api.test2.com")!)
        let request3 = NSMutableURLRequest(URL: NSURL(string: "http://api.test2.com")!)
        let request4 = NSMutableURLRequest(URL: NSURL(string: "http://api.test2.com")!)
        
        var numberOfCalls = 0
        let checker: (NSData?, NSURLResponse?, NSError?) -> () = { (data, response, anError) in
            
            guard let httpResponse = response as? NSHTTPURLResponse else { fatalError("\(response) should be a NSHTTPURLResponse") }
            
            numberOfCalls += 1
            
            switch numberOfCalls {
            case 1:
                XCTAssertEqual(httpResponse.URL!.absoluteString, "http://api.test1.com")
            case 2...4:
                XCTAssertEqual(httpResponse.URL!.absoluteString, "http://api.test2.com")
                if numberOfCalls == 4 {
                    expectation.fulfill()
                }
            default: break
            }
        }
        
        turnatable.dataTaskWithRequest(request1, completionHandler: checker).resume()
        turnatable.dataTaskWithRequest(request2, completionHandler: checker).resume()
        turnatable.dataTaskWithRequest(request3, completionHandler: checker).resume()
        turnatable.dataTaskWithRequest(request4, completionHandler: checker).resume()
    }
    
    
    func test_Vinyl_multiple_uniquely() {
        
        let expectation = self.expectationWithDescription("Expected callback to have the correct URL")
        defer { self.waitForExpectationsWithTimeout(4, handler: nil) }
        
        let turnatable = Turntable(
            vinylName: "vinyl_multiple",
            turntableConfiguration: TurntableConfiguration(matchingStrategy: .RequestAttributes(types: [.URL], playTracksUniquely: true)))
        
        let request1 = NSMutableURLRequest(URL: NSURL(string: "http://api.test1.com")!)
        let request2 = NSMutableURLRequest(URL: NSURL(string: "http://api.test2.com")!)
        
        let mockedTrackedNotFound = MockedTrackedNotFoundErrorHandler { expectation.fulfill() }
        turnatable.errorHandler = mockedTrackedNotFound
        
        var numberOfCalls = 0
        let checker: (NSData?, NSURLResponse?, NSError?) -> () = { (data, response, anError) in
            
            guard let httpResponse = response as? NSHTTPURLResponse else { fatalError("\(response) should be a NSHTTPURLResponse") }
            
            switch numberOfCalls {
            case 0:
                XCTAssertEqual(httpResponse.URL!.absoluteString, "http://api.test1.com")
                numberOfCalls += 1
            case 1:
                XCTAssertEqual(httpResponse.URL!.absoluteString, "http://api.test2.com")
                numberOfCalls += 1
            case 2:
                fatalError("This shouldn't be reached")
            default: break
            }
        }
        
        turnatable.dataTaskWithRequest(request1, completionHandler: checker).resume()
        turnatable.dataTaskWithRequest(request2, completionHandler: checker).resume()
        turnatable.dataTaskWithRequest(request2, completionHandler: checker).resume()
        turnatable.dataTaskWithRequest(request2, completionHandler: checker).resume()
        turnatable.dataTaskWithRequest(request2, completionHandler: checker).resume()
    }
    
    //MARK: Aux methods
    
    private func singleCallTest(turnatable: Turntable) {
        
        let expectation = self.expectationWithDescription("Expected callback to have the correct URL")
        defer { self.waitForExpectationsWithTimeout(4, handler: nil) }
        
        let request = NSURLRequest(URL: NSURL(string: "http://api.test.com")!)
        
        turnatable.dataTaskWithRequest(request) { (data, response, anError) in
            
            XCTAssertNil(anError)
            
            guard let httpResponse = response as? NSHTTPURLResponse else { fatalError("\(response) should be a NSHTTPURLResponse") }
            
            let body = "hello".dataUsingEncoding(NSUTF8StringEncoding)!
                        
            XCTAssertEqual(httpResponse.URL!.absoluteString, "http://api.test.com")
            XCTAssertEqual(httpResponse.statusCode, 200)
            XCTAssertTrue(data!.isEqualToData(body))
            XCTAssertNotNil(httpResponse.allHeaderFields)
            
            expectation.fulfill()
            }.resume()
    }
    
    private func multipleCallTest(turnatable: Turntable) {
        
        let expectation = self.expectationWithDescription("Expected callback to have the correct URL")
        defer { self.waitForExpectationsWithTimeout(4, handler: nil) }
        
        let request1 = NSURLRequest(URL: NSURL(string: "http://api.test1.com")!)
        let request2 = NSURLRequest(URL: NSURL(string: "http://api.test2.com")!)
        
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
        
        turnatable.dataTaskWithRequest(request1, completionHandler: checker).resume()
        turnatable.dataTaskWithRequest(request2, completionHandler: checker).resume()
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
                
                if let responseHeaders = httpResponse.allHeaderFields as? HTTPHeaders, let originalHeaders = track.response.urlResponse.allHeaderFields as? HTTPHeaders {
                    XCTAssertTrue(responseHeaders == originalHeaders)
                }
                
                XCTAssertTrue(httpResponse.URL == track.response.urlResponse.URL)
                
                tracks.removeAtIndex(tracks.indexOf(track)!)
            }
            
            if tracks.isEmpty {
                expectation.fulfill()
            }
        }
        
        let turnatable = Turntable(
            turntableConfiguration: TurntableConfiguration(matchingStrategy: .TrackOrder),
            vinyl: Vinyl(tracks: tracks))
            
        turnatable.dataTaskWithRequest(request1, completionHandler: checker).resume()
        turnatable.dataTaskWithRequest(request2, completionHandler: checker).resume()
        turnatable.dataTaskWithRequest(request3, completionHandler: checker).resume()
    }
}
