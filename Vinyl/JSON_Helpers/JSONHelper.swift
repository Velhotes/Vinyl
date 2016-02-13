//
//  JSONHelper.swift
//  Vinyl
//
//  Created by Rui Peres on 12/02/2016.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

func loadJSON<T>(bundle: NSBundle, fileName: String) -> T?  {
    
    guard
        let path = bundle.pathForResource(fileName, ofType: "json"),
        data = NSData(contentsOfFile: path),
        jsonData = try? NSJSONSerialization.JSONObjectWithData(data, options: []) as? T
        else { return nil }
    
    return jsonData
}
