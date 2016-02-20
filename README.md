<p align="center">
<img src="https://dl.dropboxusercontent.com/u/14102938/1455301679_gramphone.png">
</p>

Vinyl
-----

[![Build Status](https://travis-ci.org/Velhotes/Vinyl.svg?branch=master)](https://travis-ci.org/Velhotes/Vinyl)
[![codecov.io](https://codecov.io/github/Velhotes/Vinyl/coverage.svg?branch=master)](https://codecov.io/github/Velhotes/Vinyl?branch=master)
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
[![Swift 2.1](https://img.shields.io/badge/Swift-2.1-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat)](https://opensource.org/licenses/MIT)

Vinyl is a simple, yet flexible library used for replaying HTTP requests while unit testing. It takes heavy inspiration from [DVR](https://github.com/venmo/DVR) and [VCR](https://github.com/vcr/vcr).

Vinyl should be used when you design your app's architecture with [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection) in mind. For other cases, where your `NSURLSession` is fixed, we would recommend [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs) or [Mockingjay](https://github.com/kylef/Mockingjay). 

## How to use it

#### Carthage

```
github "Velhotes/Vinyl" "0.9"
```

#### Intro
Vinyl uses the same nomenclature that you would see in real life, when playing a vinyl:

* `Turntable`
* `Vinyl`
* `Track`

Let's start with the most basic configuration, where you already have a track (stored in the `vinyl_single`):

```swift
let turntable = Turntable(vinylName: "vinyl_single")
let request = NSURLRequest(URL: NSURL(string: "http://api.test.com")!)
 
turntable.dataTaskWithRequest(request) { (data, response, anError) in
 // Assert your expectations    
}.resume()
```

A track is a mapping between a request (`NSURLRequest`) and a response (`NSHTTPURLResponse` + `NSData?` + `NSError?`). As expected, the `vinyl_single` that you are seeing in the example above is exactly that:

```json
[
  {
    "request": {
        "url": "http://api.test.com"
    },
    "response": {
        "url": "http://api.test.com",
        "body": "hello",
        "status": 200,
        "headers": {}
    }
  }
]
```
Vinyl by default will use the mapping approach. Internally, we will try to match the request sent with the track recorded based on:

*  The sent request's `URL` with the track request's `URL`. 
*  The sent request's `HTTPMethod` with the track request's `HTTPMethod`. 

As you might have noticed, we don't provide an `HTTPMethod` in the `vinyl_single`, by default it will fallback to `.GET`.

If the mapping doesn't suit your needs, you can customize it by:

```swift
enum RequestMatcherType {
    case Method
    case URL
    case Path
    case Query
    case Headers
    case Body
    case Custom(RequestMatcher)
}
```

In practise it would look like this:

```swift
let matching = .RequestAttributes(types: [.Body, .Query], playTracksUniquely: true)
let configuration = TurntableConfiguration( matchingStrategy:  matching)
let turntable = Turntable( vinylName: "vinyl_simple", turntableConfiguration: configuration)
```
In this case we are matching by `.Body` and `.Query`. We also provide a way of making sure each track is only played once (or not), by setting the `playTracksUniquely` accordingly. 

If the mapping approach is not desirable, you can make it behave like a queue: the first request will match the first response in the array and so on:

```swift
let matching = .TrackOrder
let configuration = TurntableConfiguration( matchingStrategy:  matching)
let turntable = Turntable( vinylName: "vinyl_simple", turntableConfiguration: configuration)
```
Finally we allow you to create a track by hand, instead of relying on a JSON file:

```swift
let track = TrackFactory.createValidTrack(NSURL(string: "http://feelGoodINC.com")!, body: data, headers: headers)

let vinyl = Vinyl(tracks: [track])
let turntable = Turntable(vinyl: vinyl, turntableConfiguration: configuration)
```

#### Coming from DVR

If your tests are already working with DVR, you will probably have pre-recorded cassettes. Vinyl provides a compatibility mode that allows you to re-use those cassettes. 

If your tests look like this:

```swift
let session = Session(cassetteName: "dvr_single")
```
You can just use a `Turntable` instead:

```swift
let turntable = Turntable(cassetteName: "dvr_single")
```

That way you won't have to throw anything away.

## Current Status

The current version ([0.9](https://github.com/Velhotes/Vinyl/releases/tag/0.9.0)) is currently being used in a project successfully. This gives us some degree of confidence it will work for you as well. **Nevertheless don't forget this is a pre-release version**. If there is something that isn't working for you, or you are finding its usage cumbersome, please [let us know](https://github.com/Velhotes/Vinyl/issues/new). 

For the 1.0 release, we are planning to have the ability to record requests. In the meantime if you don't have any JSON pre recorded response, you should create your own `Track` manually (either by code, or with a JSON file). 

## Roadmap

* [X] Allow the user to configure how strict the library should be.
* [X] Allow the user to define their own response without relying on a json file.
* [X] Instead of mapping requests ➡️ responses , fix the responses in an array (e.g. first request made will use the first response in the array and so on).
* [ ] Allow request recording.
* [ ] Debug mode ([#28](https://github.com/Velhotes/Vinyl/issues/28))

## Why not simply use DVR?

From our point of view, DVR is too strict. If you change something in your request, even if you are expecting the same response, your tests will break. With that in mind, we intend to follow VCR's approach, where you can define what should be fixed, and what's not (e.g. only care if the `NSURL` changes, instead of the headers, body and HTTP Method). Bottom line, our approach will have flexibility and extensibility in mind.

We also feel that the DVR project has stalled. As of 15/02/2016, the project has 10 issues open, 2 PRs and the last commit was more than one month ago. 

## Contributing

We will gladly accept Pull Requests that take the roadmap into consideration. Documentation, or tests, are always welcome as well. :heart:


