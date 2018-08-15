<p align="center">
<img src="https://dl.dropboxusercontent.com/u/14102938/1455301679_gramphone.png">
</p>

Vinyl
-----

[![Version](https://img.shields.io/badge/version-0.10.0-blue.svg)](https://github.com/Velhotes/Vinyl/releases/latest)
[![Build Status](https://travis-ci.org/Velhotes/Vinyl.svg?branch=master)](https://travis-ci.org/Velhotes/Vinyl)
[![codecov.io](https://codecov.io/github/Velhotes/Vinyl/coverage.svg?branch=master)](https://codecov.io/github/Velhotes/Vinyl?branch=master)
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
[![Swift 3.0](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat)](https://opensource.org/licenses/MIT)
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20OS%20X%20%7C%20tvOS%20-lightgrey.svg)

Vinyl is a simple, yet flexible library used for replaying HTTP requests while unit testing. It takes heavy inspiration from [DVR](https://github.com/venmo/DVR) and [VCR](https://github.com/vcr/vcr).

Vinyl should be used when you design your app's architecture with [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection) in mind. For other cases, where your `URLSession` is fixed, we would recommend [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs) or [Mockingjay](https://github.com/kylef/Mockingjay). 

## How to use it

#### Carthage

```
github "Velhotes/Vinyl" "0.10.0"
```

#### Intro
Vinyl uses the same nomenclature that you would see in real life, when playing a vinyl:

* `Turntable`
* `Vinyl`
* `Track`

Let's start with the most basic configuration, where you already have a track (stored in the `vinyl_single`):

```swift
let turntable = Turntable(vinylName: "vinyl_single")
let request = URLRequest(url: URL(string: "http://api.test.com")!)
 
turntable.dataTask(with: request) { (data, response, anError) in
 // Assert your expectations    
}.resume()
```

A track is a mapping between a request (`URLRequest`) and a response (`HTTPURLResponse` + `Data?` + `Error?`). As expected, the `vinyl_single` that you are seeing in the example above is exactly that:

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

*  The sent request's `url` with the track request's `url`. 
*  The sent request's `httpMethod` with the track request's `httpMethod`. 

As you might have noticed, we don't provide an `httpMethod` in the `vinyl_single`, by default it will fallback to `GET`.

If the mapping doesn't suit your needs, you can customize it by:

```swift
enum RequestMatcherType {
    case method
    case url
    case path
    case query
    case headers
    case body
    case custom(RequestMatcher)
}
```

In practise it would look like this:

```swift
let matching = MatchingStrategy.requestAttributes(types: [.body, .query], playTracksUniquely: true)
let configuration = TurntableConfiguration(matchingStrategy:  matching)
let turntable = Turntable(vinylName: "vinyl_simple", turntableConfiguration: configuration)
```
In this case we are matching by `.body` and `.query`. We also provide a way of making sure each track is only played once (or not), by setting the `playTracksUniquely` accordingly. 

If the mapping approach is not desirable, you can make it behave like a queue: the first request will match the first response in the array and so on:

```swift
let matching = MatchingStrategy.trackOrder
let configuration = TurntableConfiguration(matchingStrategy:  matching)
let turntable = Turntable(vinylName: "vinyl_simple", turntableConfiguration: configuration)
```
We also allow creating a track by hand, instead of relying on a JSON file:

```swift
let track = TrackFactory.createValidTrack(url: URL(string: "http://feelGoodINC.com")!, body: data, headers: headers)

let vinyl = Vinyl(tracks: [track])
let turntable = Turntable(vinyl: vinyl, turntableConfiguration: configuration)
```

If you have a custom configuration that you would like to see shared among your tests, we recommend the following:

```swift
class FooTests: XCTestCase {
    let turntable = Turntable(turntableConfiguration: TurntableConfiguration(matchingStrategy: .trackOrder))

    func test_1() {
       turntable.loadVinyl("vinyl_1")
       // Use the turntable
    }

    func test_2() {
       turntable.loadVinyl("vinyl_1")
       // Use the turntable
    }
}
```

This approach cuts the unnecessary boilerplate (you will also feel like a  ✨🎶Dj 🎶✨)

#### Coming from [Alamofire](https://github.com/Alamofire/Alamofire)

Instead of using the [default manager](https://github.com/Alamofire/Alamofire/blob/master/Source/SessionManager.swift#L48), initialize a new one via:

```swift
public init?(
    session: URLSession,
    delegate: SessionDelegate,
    serverTrustPolicyManager: ServerTrustPolicyManager? = nil)
    {
        guard delegate === session.delegate else { return nil }

        self.delegate = delegate
        self.session = session

        commonInit(serverTrustPolicyManager: serverTrustPolicyManager)
    }
```

Your network layer, could then be in the form of:

```swift
class Network {
    private let manager: SessionManager
  
    init(session: URLSession) {
        self.manager = SessionManager(session: session, delegate: SessionDelegate())
    }
}
```

This way it's becomes quite easy to test your components using Vinyl. This might be too cumbersome for some users, so don't forget that you still have the `URLProtocol` approach (with [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs) and [Mockingjay](https://github.com/kylef/Mockingjay)).

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

> Note: only use it for cassettes that you already have in the bundle, otherwise recording will crash trying to read missing file.

## Recording

You can also use Vinyl to record requests and responses from the network to use for future testing. This is an easy way to create Vinyls and Tracks automatically with genuine data rather than creating them manually.

There are 3 recording modes:
* `.none` - recording is disabled.
* `.missingVinyl` - will record a new Vinyl if the named Vinyl does not exist. This is the default mode.
* `.missingTracks` - will record new Tracks to an existing Vinyl where the Track is not found.

Both `.missingVinyl` and `.missingTracks` allow you to specify a `recordingPath` for where to save the recordings (this should be a file path). If the path is not provided (`nil`) then the default path is current test target's Resource Bundle, which is also the default location from which Vinyl's are loaded.

#### A simple example

```swift
let recordingMode = RecordingMode.missingVinyl(recordingPath: nil)
let configuration = TurntableConfiguration(recordingMode: recordingMode)
let turntable = Turntable(vinylName: "new_vinyl", turntableConfiguration: configuration)
let request = URLRequest(url: URL(string: "http://api.test.com")!)
 
turntable.dataTask(with: request) { (data, response, anError) in
    // Assert your expectations    
}.resume()
```

The `recordingMode` in the example above is actually the default, but it's shown explicitly to make it clearer. With the above configuration, if "new_vinyl.json" does't exist it is created and the request will be made over the network. Both the request and response will be recorded.

Recordings are saved either when the `Turntable` is deinitialized or you can explicitly call `turntable.stopRecording()` which will persist the recorded data.

You can provide a `URLSession` for a `Turntable` to use for making network requests:

`let turntable = Turntable(vinylName: "new_vinyl", turntableConfiguration: configuration, urlSession: aSession)`

If no `URLSession` is provided, it defaults to `URLSession.shared`.

## Current Status

The current version ([0.10](https://github.com/Velhotes/Vinyl/releases/tag/0.10.0)) is currently being used in a project successfully. This gives us some degree of confidence it will work for you as well. **Nevertheless don't forget this is a pre-release version**. If there is something that isn't working for you, or you are finding its usage cumbersome, please [let us know](https://github.com/Velhotes/Vinyl/issues/new).  

## Roadmap

* [X] Allow the user to configure how strict the library should be.
* [X] Allow the user to define their own response without relying on a json file.
* [X] Instead of mapping requests ➡️ responses , fix the responses in an array (e.g. first request made will use the first response in the array and so on).
* [X] Allow request recording. ([#12](https://github.com/Velhotes/Vinyl/issues/12))
* [ ] Debug mode ([#28](https://github.com/Velhotes/Vinyl/issues/28))

## Why not simply use DVR?

From our point of view, DVR is too strict. If you change something in your request, even if you are expecting the same response, your tests will break. With that in mind, we intend to follow VCR's approach, where you can define what should be fixed, and what's not (e.g. only care if the `NSURL` changes, instead of the headers, body and HTTP Method). Bottom line, our approach will have flexibility and extensibility in mind.

We also feel that the DVR project has stalled. As of 15/02/2016, the project has 10 issues open, 2 PRs and the last commit was more than one month ago. 

## Contributing

We will gladly accept Pull Requests that take the roadmap into consideration. Documentation, or tests, are always welcome as well. :heart:


