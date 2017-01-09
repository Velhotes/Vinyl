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
    func match(lhs: Request, rhs: Request) -> Bool
}

public struct RequestMatcherRegistry {
    
    fileprivate let registeredTypes: [RequestMatcherType]
    fileprivate let matchingChain: [RequestMatcher]
    
    init(types: [RequestMatcherType]) {
        registeredTypes = types
        matchingChain = types.map { RequestMatcherRegistry.matcher(for: $0) }
    }
    
    func matchableRequests(request: Request, with anotherRequest: Request) -> Bool {        
        return matchingChain.all { $0.match(lhs: request, rhs: anotherRequest) }
    }
    
    fileprivate static func matcher(for requestMatcherType: RequestMatcherType) -> RequestMatcher {
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
    func match(lhs: Request, rhs: Request) -> Bool {
        // `caseInsensitiveCompare` doesn't support an optional, to prevent unwrapping and perform more than one comparison we can capitalize both methods and rely on optionals to do the hard-work
        return lhs.httpMethod?.capitalized == rhs.httpMethod?.capitalized
    }
}

private  struct URLRequestMatcher: RequestMatcher {
    func match(lhs: Request, rhs: Request) -> Bool {
        return lhs.url == rhs.url
    }
}

private  struct PathRequestMatcher: RequestMatcher {
    func match(lhs: Request, rhs: Request) -> Bool {
        return lhs.url?.path == rhs.url?.path
    }
}

private struct QueryRequestMatcher: RequestMatcher {
    func match(lhs: Request, rhs: Request) -> Bool {
        
        let queryItems: (Request) -> [URLQueryItem] = { request in
            let components = URLComponents(string: request.url?.absoluteString ?? "")
            return components?.queryItems ?? []
        }
        
        let lhsItems = queryItems(lhs).sorted(by: >)
        let rhsItems = queryItems(rhs).sorted(by: >)
    
        return lhsItems == rhsItems
    }
}

private struct HeadersRequestMatcher: RequestMatcher {
    func match(lhs: Request, rhs: Request) -> Bool {
        
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
        
        let lhsLoweredHeaders = loweredHeaders(lhs)
        let rhsLoweredHeaders = loweredHeaders(rhs)

        return lhsLoweredHeaders == rhsLoweredHeaders
    }
}

private struct BodyRequestMatcher: RequestMatcher {
    func match(lhs: Request, rhs: Request) -> Bool {

        switch (lhs.httpBody, rhs.httpBody) {
        case (.none, .none): return true
        case (.some(let lhsData), .some(let rhsData)):
            guard let lhsHeaders = lhs.allHTTPHeaderFields,
                let rhsHeaders = rhs.allHTTPHeaderFields,
                let lhsBody = encode(body: lhsData, headers: lhsHeaders),
                let rhsBody = encode(body: rhsData, headers: rhsHeaders) else { return lhsData == rhsData }
            return (lhsBody as AnyObject).isEqual(rhsBody as AnyObject)
        default: return false
        }
    }
}
