//
//  FuncComposition.swift
//  Vinyl
//
//  Created by Rui Peres on 16/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

precedencegroup VinylPrecedenceLeft {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator ~> : VinylPrecedenceLeft

func ~> <T, U, V>(f: @escaping (T) -> U, g: @escaping (U) -> V) -> (T) -> V {
    
    return { g(f($0)) }
}
