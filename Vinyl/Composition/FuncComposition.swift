//
//  FuncComposition.swift
//  Vinyl
//
//  Created by Rui Peres on 16/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

infix operator ~> { associativity left }

func ~> <T, U, V>(f: T -> U, g: U -> V) -> T -> V {
    
    return { g(f($0)) }
}