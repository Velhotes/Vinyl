//
//  RequestMatcherRegistry.swift
//  Vinyl
//
//  Created by David Rodrigues on 15/02/16.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

enum RequestMatcherType {
    case Method
    case URL
    case Path
    case Query
    case Headers
    case Body
    case Custom(RequestMatcher)
}

protocol RequestMatcher {
    func match(aRequest: Request, anotherRequest: Request) -> Bool
}

struct RequestMatcherRegistry {
    
    let registeredTypes: [RequestMatcherType]
    
    private let matchingChain: [RequestMatcher]
    
    init(types: [RequestMatcherType]) {
        registeredTypes = types
        matchingChain = types.map { RequestMatcherRegistry.matcherForType($0) }
    }
    
    func matchableRequests(aRequest: Request, anotherRequest: Request) -> Bool {
        for requestMatcher in matchingChain {
            if !requestMatcher.match(aRequest, anotherRequest: anotherRequest) {
                return false
            }
        }
        return true
    }
    
    private static func matcherForType(requestMatcherType: RequestMatcherType) -> RequestMatcher {
        switch requestMatcherType {
        case .Method:
            return MethodRequestMatcher()
        case .URL:
            return URLRequestMatcher()
        case .Path:
            return PathRequestMatcher()
        case .Query:
            return QueryRequestMatcher()
        case .Headers:
            return HeadersRequestMatcher()
        case .Body:
            return BodyRequestMatcher()
        case .Custom(let customRequestMatcher):
            return customRequestMatcher
        }
    }
}

// MARK: Matchers

struct MethodRequestMatcher: RequestMatcher {
    func match(aRequest: Request, anotherRequest: Request) -> Bool {
        // `caseInsensitiveCompare` doesn't support an optional, to prevent unwrapping and perform more than one comparison we can capitalize both methods and rely on optionals to do the hard-work
        return aRequest.HTTPMethod?.capitalizedString == anotherRequest.HTTPMethod?.capitalizedString
    }
}

struct URLRequestMatcher: RequestMatcher {
    func match(aRequest: Request, anotherRequest: Request) -> Bool {
        return aRequest.URL == anotherRequest.URL
    }
}

struct PathRequestMatcher: RequestMatcher {
    func match(aRequest: Request, anotherRequest: Request) -> Bool {
        return aRequest.URL?.path == anotherRequest.URL?.path
    }
}

struct QueryRequestMatcher: RequestMatcher {
    func match(aRequest: Request, anotherRequest: Request) -> Bool {
        
        let queryItems: Request -> [NSURLQueryItem]  = { request in
            let components = NSURLComponents.init(string: request.URL?.absoluteString ?? "")
            return components?.queryItems ?? []
        }
        
        let aRequestItems = queryItems(aRequest).sort(>)
        let anotherRequestItems = queryItems(anotherRequest).sort(>)
    
        return aRequestItems == anotherRequestItems
    }
}

struct HeadersRequestMatcher: RequestMatcher {
    func match(aRequest: Request, anotherRequest: Request) -> Bool {
        
        let headers: Request -> [String: String]  = { request in
            return request.allHTTPHeaderFields ?? [:]
        }
        
        let toLowerCase: [String: String] -> [String: String] = {dic in
        
            var loweredCase: [String: String] = [:]
            for key in dic.keys {
                loweredCase[key.lowercaseString] = dic[key]?.lowercaseString
            }
            return loweredCase
        }

        let loweredHeaders = headers ~> toLowerCase
        
        let aRequestLoweredHeaders =  loweredHeaders(aRequest)
        let anotherRequestLoweredHeaders = loweredHeaders(anotherRequest)

        return aRequestLoweredHeaders == anotherRequestLoweredHeaders
    }
}

struct BodyRequestMatcher: RequestMatcher {
    func match(aRequest: Request, anotherRequest: Request) -> Bool {

        switch (aRequest.HTTPBody, anotherRequest.HTTPBody) {
        case (.None, .None): return true
        case (.Some(let lhsData), .Some(let rhsData)): return lhsData.isEqualToData(rhsData)
        default: return false
        }
    }
}
