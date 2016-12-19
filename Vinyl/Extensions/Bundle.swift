//
//  Bundle.swift
//  Vinyl
//
//  Created by Rui Peres on 19/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

// Idea taken from Venmo/DVR (thanks!)
func testingBundle() -> Bundle {
    
    let bundleArray = Bundle.allBundles.filter() { $0.bundlePath.hasSuffix(".xctest") }
    
    guard bundleArray.count != 0 else {
        fatalError("We were not able to find a suitable bundle, please specify it manually 🙁\nE.g:`Turntable(vinylName: \"your_vinyl\", bundle: your_bundle)`.")
    }
    
    if bundleArray.count > 1 {
        print("It seems you have more than one testing bundle, we advise specifying the bundle parameter 🙁\nE.g:`Turntable(vinylName: \"your_vinyl\", bundle: your_bundle)`.\nYour available bundles are:\n------------\(bundleArray)\n------------\nAnd we are going to use \(bundleArray.first!)\n")
    }
    
    return bundleArray.first!
}
