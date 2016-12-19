//
//  URLQueryItem.swift
//  Vinyl
//
//  Created by Rui Peres on 16/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

extension URLQueryItem: Comparable { }

public func < (lhs: URLQueryItem, rhs: URLQueryItem) -> Bool {
    
    return lhs.name < rhs.name
}
