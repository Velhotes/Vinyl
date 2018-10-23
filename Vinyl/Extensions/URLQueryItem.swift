//
//  URLQueryItem.swift
//  Vinyl
//
//  Created by Rui Peres on 16/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

extension URLQueryItem: Comparable {
    
    public static func < (lhs: URLQueryItem, rhs: URLQueryItem) -> Bool {
        guard lhs.name < rhs.name else { return false }
        switch (lhs.value, rhs.value) {
        case let (lhs?, rhs?): return lhs < rhs
        case (nil, nil): return false
        default: return lhs.value == nil
        }
    }
}
