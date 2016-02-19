<p align="center">
<img src="https://dl.dropboxusercontent.com/u/14102938/1455301679_gramphone.png">
</p>

Vinyl
-----

[![Build Status](https://travis-ci.org/Velhotes/Vinyl.svg?branch=master)](https://travis-ci.org/Velhotes/Vinyl)

Vinyl is a simple, yet flexible library used for replaying HTTP requests while unit testing. It takes heavy inspiration from [DVR](https://github.com/venmo/DVR) and [VCR](https://github.com/vcr/vcr).

Vinyl should be used, when you design your app's architecture with [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection) in mind. For other cases, where your `NSURLSession` is fixed, we would recommend [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs) or [Mockingjay](https://github.com/kylef/Mockingjay). 

### How to use it
-

#### Intro
Vinyl uses the same nomenclature that you would see in real life, when playing a vinyl:

* Turntable
* Vinyl
* Track

Let's start with the most basic configuration, where you already have a pre-recorded response and you just want to use it:

```swift
let turntable = Turntable(vinylName: "vinyl_single")
let request = NSURLRequest(URL: NSURL(string: "http://api.test.com")!)
 
turnatable.dataTaskWithRequest(request) { (data, response, anError) in
 // Assert your expectations    
}.resume()
```

A pre-recorded response is a mapping between a request (`NSURLRequest`) and a response (`NSHTTPURLResponse` + `NSData?` + `NSError?`). As expected, the `vinyl_single` that you are seeing in the example above is exactly that:

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
Vinyl by default will use the mapping approach. Internally, we will try to match the request sent  with the request recorded based:

*  The sent request's `URL` with the  recorded request's `URL`. 
*  The sent request's `HTTPMethod` with the recorded request's `HTTPMethod`. 

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
let matching = .RequestAttributes(types: [.URL, .Query], playTracksUniquely: true)
let configuration = TurntableConfiguration( matchingStrategy:  matching)
let turnatable = Turntable( vinylName: "vinyl_simple", turntableConfiguration: configuration)
```
In this case we are matching by `.URL` and `.Query`. We also provide a way of making sure each track is only played once (or not), by setting the `playTracksUniquely` accordingly. 

If the mapping approach is not desirable, you can make it behave like a queue: the first request will match the first response in the array and so on:

```swift
let matching = .TrackOrder
let configuration = TurntableConfiguration( matchingStrategy:  matching)
let turnatable = Turntable( vinylName: "vinyl_simple", turntableConfiguration: configuration)
```
Finally we allow you to create a track by hand, instead of relying on a JSON file:

```swift
let track = TrackFactory.createValidTrack(NSURL(string: "http://feelGoodINC.com")!, body: data, headers: headers)

let vinyl = Vinyl(tracks: [track])
let turnatable = Turntable(vinyl: vinyl, turntableConfiguration: configuration)
```

#### Coming from DVR

If your tests are already working with DVR, you will probably have pre-recorded cassettes. Vinyl provides a compatibility mode that allows you to re-use those cassettes. 

If your tests look like this:

```swift
let session = Session(cassetteName: "dvr_single")
```
You can just use a `Turntable` instead:

```swift
let turnatable = Turntable(cassetteName: "dvr_single")
```

This way you won't have to throw anything away.

### Current Status
-
We advise against its usage right now, until version 1.0 is released. Once we have our first release, we will update this README with a section on "How to Use it".

### Roadmap
-
* [X] Allow the user to configure how strict the library should be.
* [X] Allow the user to define its own response without relying on a json file.
* [X] Instead mapping requests ➡️ responses , fix the responses in an array (e.g. first request made will use the first response in the array and so on).
* [ ] Allow request recording.
* [ ] Debug mode ([#28](https://github.com/Velhotes/Vinyl/issues/28))

### Why not simply use DVR?
-
From our point of view, DVR is too strict. If you change something in your request, even if you are expecting the same response, your tests will break. With that in mind, we intend to follow VCR's approach, where you can define what should be fixed, and what's not (e.g. only care if the `NSURL` changes, instead of the headers, body and HTTP Method). Bottom line, our approach will have flexibility and extensibility in mind.

We also feel, that the DVR project has staled. As of 15/02/2016, the project has 10 issues open, 2 PR and the last commit was more than one month ago. 

### Contributing
-
We will gladly accept Pull Requests that take the roadmap into consideration. Documentation, or tests, are always welcome as well. :heart:


