//
//  Arbitrary.swift
//  Vinyl
//
//  Created by Robert Widmann on 2/20/16.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation
import SwiftCheck

/// Generates an array of lowercase alphabetic `Character`s.
let lowerStringGen =
Gen<Character>.fromElements(in: "a"..."z")
    .proliferateNonEmpty
    .map(String.init)

/// Generates a URL of the form `(http|https)://<domain>.com`.
let urlStringGen : Gen<String> = sequence([
    Gen<String>.fromElements(of: ["http://", "https://"]),
    lowerStringGen,
    Gen.pure(".com"),
    ])
    .map { $0.reduce("", +) }

// Generates a JSON string of the form '"string"'
let jsonString: Gen<String> = lowerStringGen.map { "\"" + $0 + "\""}

// Generates a JSON string pair of the form '"key":"value"'
let jsonStringPair: Gen<String> = sequence([
    jsonString,
    Gen.pure(":"),
    jsonString])
    .map { $0.reduce("", +) }

// Generates a JSON string pair of the form '"key":"value", "key1":"value1" ....'
let jsonStringPairs: Gen<String> =  Gen.sized { sz in
    return jsonStringPair.proliferateSized(sz + 1)
    } .map { xs in
        return xs.reduce("") { $0 == "" ? $1 : $0 + "," + $1 }
}

// Generates a JSON of the form '{"key":"value", "key1":"value1" .... }'
let basicJSONDic : Gen<AnyObject> = sequence([
    Gen.pure("{"),
    jsonStringPairs,
    Gen.pure("}")
    ])
    .map { $0.reduce("", +) }
    .map { $0.data(using: .utf8)! }
    .map { try! JSONSerialization.jsonObject(with: $0, options: .allowFragments) as AnyObject }

/// Generates a path of the form `<some>/<path>/<to>/.../<somewhere>`.
let urlPathGen : Gen<String> =
(curry(+) <^> Gen.pure("/") <*> lowerStringGen)
    .proliferate
    .map { $0.reduce("", combine: +) }

/// Generates an array of parameters of the form `<param>=<arg>`,
let parameterGen : Gen<String> = sequence([
    lowerStringGen,
    Gen.pure("="),
    lowerStringGen,
    ])
    .map { $0.reduce("", +) }

/// Generates a set of parameters.
let pathParameterGen : Gen<String> = Gen.sized { sz in
    return parameterGen.proliferateSized(sz + 1)
    } .map { xs in
        return xs.reduce("?") { $0 == "?" ? "?" + $1 : $0 + "&" + $1 }
}

private func curry<A, B, C>(_ f : @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in { b in f(a, b) } }
}

extension Dictionary {
    init<S : Sequence>(_ pairs : S) where S.Iterator.Element == Element {
        self.init()
        var g = pairs.makeIterator()
        while let (k, v) : (Key, Value) = g.next() {
            self[k] = v
        }
    }
}
