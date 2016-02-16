//
//  NSURLQueryItem.swift
//  Vinyl
//
//  Created by Rui Peres on 16/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

extension NSURLQueryItem: Comparable { }

public func < (lhs: NSURLQueryItem, rhs: NSURLQueryItem) -> Bool {
    
    return lhs.name < rhs.name
}