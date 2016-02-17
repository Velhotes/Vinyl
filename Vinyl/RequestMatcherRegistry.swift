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
    
    private let registeredTypes: [RequestMatcherType]
    private let matchingChain: [RequestMatcher]
    
    init(types: [RequestMatcherType]) {
        registeredTypes = types
        matchingChain = types.map { RequestMatcherRegistry.matcherForType($0) }
    }
    
    func matchableRequests(aRequest: Request, anotherRequest: Request) -> Bool {
        
        return matchingChain.all { $0.match(aRequest, anotherRequest: anotherRequest) }
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

private struct MethodRequestMatcher: RequestMatcher {
    func match(aRequest: Request, anotherRequest: Request) -> Bool {
        // `caseInsensitiveCompare` doesn't support an optional, to prevent unwrapping and perform more than one comparison we can capitalize both methods and rely on optionals to do the hard-work
        return aRequest.HTTPMethod?.capitalizedString == anotherRequest.HTTPMethod?.capitalizedString
    }
}

private  struct URLRequestMatcher: RequestMatcher {
    func match(aRequest: Request, anotherRequest: Request) -> Bool {
        return aRequest.URL == anotherRequest.URL
    }
}

private  struct PathRequestMatcher: RequestMatcher {
    func match(aRequest: Request, anotherRequest: Request) -> Bool {
        return aRequest.URL?.path == anotherRequest.URL?.path
    }
}

private struct QueryRequestMatcher: RequestMatcher {
    func match(aRequest: Request, anotherRequest: Request) -> Bool {
        
        let queryItems: Request -> [NSURLQueryItem] = { request in
            let components = NSURLComponents(string: request.URL?.absoluteString ?? "")
            return components?.queryItems ?? []
        }
        
        let aRequestItems = queryItems(aRequest).sort(>)
        let anotherRequestItems = queryItems(anotherRequest).sort(>)
    
        return aRequestItems == anotherRequestItems
    }
}

private struct HeadersRequestMatcher: RequestMatcher {
    func match(aRequest: Request, anotherRequest: Request) -> Bool {
        
        let headers: Request -> HTTPHeaders  = { request in
            return request.allHTTPHeaderFields ?? [:]
        }
        
        let toLowerCase: HTTPHeaders -> HTTPHeaders = { dic in
        
            var loweredCase: HTTPHeaders = [:]
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

private struct BodyRequestMatcher: RequestMatcher {
    func match(aRequest: Request, anotherRequest: Request) -> Bool {

        switch (aRequest.HTTPBody, anotherRequest.HTTPBody) {
        case (.None, .None): return true
        case (.Some(let lhsData), .Some(let rhsData)): return lhsData.isEqualToData(rhsData)
        default: return false
        }
    }
}
