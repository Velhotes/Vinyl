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
    func match(request: Request, with anotherRequest: Request) -> Bool
}

public struct RequestMatcherRegistry {
    
    fileprivate let registeredTypes: [RequestMatcherType]
    fileprivate let matchingChain: [RequestMatcher]
    
    init(types: [RequestMatcherType]) {
        registeredTypes = types
        matchingChain = types.map { RequestMatcherRegistry.matcher(for: $0) }
    }
    
    func matchableRequests(request: Request, with anotherRequest: Request) -> Bool {        
        return matchingChain.all { $0.match(request: request, with: anotherRequest) }
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
    func match(request: Request, with anotherRequest: Request) -> Bool {
        // `caseInsensitiveCompare` doesn't support an optional, to prevent unwrapping and perform more than one comparison we can capitalize both methods and rely on optionals to do the hard-work
        return request.httpMethod?.capitalized == anotherRequest.httpMethod?.capitalized
    }
}

private  struct URLRequestMatcher: RequestMatcher {
    func match(request: Request, with anotherRequest: Request) -> Bool {
        return request.url == anotherRequest.url
    }
}

private  struct PathRequestMatcher: RequestMatcher {
    func match(request: Request, with anotherRequest: Request) -> Bool {
        return request.url?.path == anotherRequest.url?.path
    }
}

private struct QueryRequestMatcher: RequestMatcher {
    func match(request: Request, with anotherRequest: Request) -> Bool {
        
        let queryItems: (Request) -> [URLQueryItem] = { request in
            let components = URLComponents(string: request.url?.absoluteString ?? "")
            return components?.queryItems ?? []
        }
        
        let requestItems = queryItems(request).sorted(by: >)
        let anotherRequestItems = queryItems(anotherRequest).sorted(by: >)
    
        return requestItems == anotherRequestItems
    }
}

private struct HeadersRequestMatcher: RequestMatcher {
    func match(request: Request, with anotherRequest: Request) -> Bool {
        
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
        
        let requestLoweredHeaders =  loweredHeaders(request)
        let anotherRequestLoweredHeaders = loweredHeaders(anotherRequest)

        return requestLoweredHeaders == anotherRequestLoweredHeaders
    }
}

private struct BodyRequestMatcher: RequestMatcher {
    func match(request: Request, with anotherRequest: Request) -> Bool {

        switch (request.httpBody, anotherRequest.httpBody) {
        case (.none, .none): return true
        case (.some(let lhsData), .some(let rhsData)):
            guard let lhsHeaders = request.allHTTPHeaderFields,
                let rhsHeaders = anotherRequest.allHTTPHeaderFields,
                let lhsBody = encode(body: lhsData, headers: lhsHeaders),
                let rhsBody = encode(body: rhsData, headers: rhsHeaders) else { return lhsData == rhsData }
            return (lhsBody as AnyObject).isEqual(rhsBody as AnyObject)
        default: return false
        }
    }
}
