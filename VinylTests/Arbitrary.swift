//
//  Arbitrary.swift
//  Vinyl
//
//  Created by Robert Widmann on 2/20/16.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import SwiftCheck

let lowerStringGen = 
	Gen<Character>.fromElementsIn("a"..."z")
	.proliferateNonEmpty
	.map(String.init)

let urlStringGen : Gen<String> = sequence([ 
	Gen.pure("http://"),
	lowerStringGen,
	Gen.pure(".com"),
].reverse()).map { $0.reduce("", combine: +) }

let urlPathGen : Gen<String> = 
	(curry(+) <^> Gen.pure("/") <*> lowerStringGen)
	.proliferate
	.map { $0.reduce("", combine: +) }

let pathParameterGen : Gen<String> = sequence([
	Gen.pure("?param1="),
	lowerStringGen,
	Gen.pure("&param2="),
	lowerStringGen,
	Gen.pure("&param3="),
	lowerStringGen,
].reverse()).map { $0.reduce("", combine: +) }

private func curry<A, B, C>(f : (A, B) -> C) -> A -> B -> C {
	return { a in { b in f(a, b) } }
}

extension Dictionary {
	init<S : SequenceType where S.Generator.Element == Element>(_ pairs : S) {
		self.init()
		var g = pairs.generate()
		while let (k, v) : (Key, Value) = g.next() {
			self[k] = v
		}
	}
}
