//
//  SequenceType.swift
//  Vinyl
//
//  Created by Rui Peres on 16/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

extension Sequence {
    
    func any(_ f: (Self.Iterator.Element) -> Bool) -> Bool {
        
        for element in self where f(element) {
            return true
        }
        
        return false
    }
    
    func all(_ f: (Self.Iterator.Element) -> Bool) -> Bool {
        
        for element in self where f(element) == false {
            return false
        }
        
        return true
    }
    
    func first(_ f: (Self.Iterator.Element) -> Bool) -> Self.Iterator.Element? {
        
        for element in self where f(element) {
            return element
        }
        
        return nil
    }
}
