//
//  NSBundle.swift
//  Vinyl
//
//  Created by Rui Peres on 19/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

// Idea taken from Venmo/DVR (thanks!)
func testingBundle() -> NSBundle {
    return NSBundle.allBundles().filter() { $0.bundlePath.hasSuffix(".xctest") }.first!
}