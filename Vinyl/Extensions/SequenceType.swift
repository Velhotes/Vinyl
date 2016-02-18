//
//  SequenceType.swift
//  Vinyl
//
//  Created by Rui Peres on 16/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

extension SequenceType {
    
    func any(@noescape f: Self.Generator.Element -> Bool) -> Bool {
        
        for element in self where f(element) {
            return true
        }
        
        return false
    }
    
    func all(@noescape f: Self.Generator.Element -> Bool) -> Bool {
        
        for element in self where f(element) == false {
            return false
        }
        
        return true
    }
    
    func first(@noescape f: Self.Generator.Element -> Bool) -> Self.Generator.Element? {
        
        for element in self where f(element) {
            return element
        }
        
        return nil
    }
}
