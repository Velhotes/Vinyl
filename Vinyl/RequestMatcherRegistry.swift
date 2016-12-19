//
//  RequestMatcherRegistry.swift
//  Vinyl
//
//  Created by David Rodrigues on 15/02/16.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

public enum RequestMatcherType {
    case method
    case url
    case path
    case query
    case headers
    case body
    case custom(RequestMatcher)
}

public protocol RequestMatcher {
    func match(_ aRequest: Request, anotherRequest: Request) -> Bool
}

public struct RequestMatcherRegistry {
    
    fileprivate let registeredTypes: [RequestMatcherType]
    fileprivate let matchingChain: [RequestMatcher]
    
    init(types: [RequestMatcherType]) {
        registeredTypes = types
        matchingChain = types.map { RequestMatcherRegistry.matcherForType($0) }
    }
    
    func matchableRequests(_ aRequest: Request, anotherRequest: Request) -> Bool {
        
        return matchingChain.all { $0.match(aRequest, anotherRequest: anotherRequest) }
    }
    
    fileprivate static func matcherForType(_ requestMatcherType: RequestMatcherType) -> RequestMatcher {
        switch requestMatcherType {
        case .method:
            return MethodRequestMatcher()
        case .url:
            return URLRequestMatcher()
        case .path:
            return PathRequestMatcher()
        case .query:
            return QueryRequestMatcher()
        case .headers:
            return HeadersRequestMatcher()
        case .body:
            return BodyRequestMatcher()
        case .custom(let customRequestMatcher):
            return customRequestMatcher
        }
    }
}

// MARK: - Matchers

private struct MethodRequestMatcher: RequestMatcher {
    func match(_ aRequest: Request, anotherRequest: Request) -> Bool {
        // `caseInsensitiveCompare` doesn't support an optional, to prevent unwrapping and perform more than one comparison we can capitalize both methods and rely on optionals to do the hard-work
        return aRequest.httpMethod?.capitalized == anotherRequest.httpMethod?.capitalized
    }
}

private  struct URLRequestMatcher: RequestMatcher {
    func match(_ aRequest: Request, anotherRequest: Request) -> Bool {
        return aRequest.url == anotherRequest.url
    }
}

private  struct PathRequestMatcher: RequestMatcher {
    func match(_ aRequest: Request, anotherRequest: Request) -> Bool {
        return aRequest.url?.path == anotherRequest.url?.path
    }
}

private struct QueryRequestMatcher: RequestMatcher {
    func match(_ aRequest: Request, anotherRequest: Request) -> Bool {
        
        let queryItems: (Request) -> [URLQueryItem] = { request in
            let components = URLComponents(string: request.url?.absoluteString ?? "")
            return components?.queryItems ?? []
        }
        
        let aRequestItems = queryItems(aRequest).sorted(by: >)
        let anotherRequestItems = queryItems(anotherRequest).sorted(by: >)
    
        return aRequestItems == anotherRequestItems
    }
}

private struct HeadersRequestMatcher: RequestMatcher {
    func match(_ aRequest: Request, anotherRequest: Request) -> Bool {
        
        let headers: (Request) -> HTTPHeaders  = { request in
            return request.allHTTPHeaderFields ?? [:]
        }
        
        let toLowerCase: (HTTPHeaders) -> HTTPHeaders = { dic in
        
            var loweredCase: HTTPHeaders = [:]
            for key in dic.keys {
                loweredCase[key.lowercased()] = dic[key]?.lowercased()
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
    func match(_ aRequest: Request, anotherRequest: Request) -> Bool {

        switch (aRequest.httpBody, anotherRequest.httpBody) {
        case (.none, .none): return true
        case (.some(let lhsData), .some(let rhsData)):
            guard let lhsHeaders = aRequest.allHTTPHeaderFields,
                let rhsHeaders = anotherRequest.allHTTPHeaderFields,
            let lhsBody = encodeBody(lhsData, headers: lhsHeaders),
            let rhsBody = encodeBody(rhsData, headers: rhsHeaders) else { return lhsData == rhsData }
            return lhsBody.isEqual(rhsBody)
        default: return false
        }
    }
}
