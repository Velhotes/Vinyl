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
        // TODO: Implement
        fatalError()
    }
}

struct HeadersRequestMatcher: RequestMatcher {
    func match(aRequest: Request, anotherRequest: Request) -> Bool {
        // TODO: Implement
        fatalError()
    }
}

struct BodyRequestMatcher: RequestMatcher {
    func match(aRequest: Request, anotherRequest: Request) -> Bool {
        // TODO: Implement
        fatalError()
    }
}
