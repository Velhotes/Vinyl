<p align="center">
<img src="https://dl.dropboxusercontent.com/u/14102938/1455301679_gramphone.png">
</p>

Vinyl
-----

[![Build Status](https://travis-ci.org/Velhotes/Vinyl.svg?branch=master)](https://travis-ci.org/Velhotes/Vinyl)

Vinyl is a simple, yet flexible library used for replaying HTTP requests while unit testing. Vinyl takes heavy inspiration from [DVR](https://github.com/venmo/DVR) and [VCR](https://github.com/vcr/vcr).

Vinyl should be used, when you design your app's architecture with Dependency Injection in mind. For other cases, where your `NSURLSession` is fixed, we would advise [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs) or [Mockingjay](https://github.com/kylef/Mockingjay). 

#### Current Status

We advise against its usage right now, until version 1.0 is released. 

#### Roadmap

* [ ] Allow the user to configure how strict the library should be.
* [ ] Instead of relying on a configuration, fix the responses in an array (e.g. first request made will use the first response in the array and so on).
* [ ] Allow request recording.
* [ ] Allow the user to define its own response without relying on a json file.

#### Why not simply use DVR?

From our point of view, DVR is too strict. If you change something in your request, even if you are expecting the same response, your tests will break. With that in mind, we intend to follow VCR's approach, where you can define what should be fixed, and what's not (e.g. only care if the `NSURL` changes, instead of the headers, body and HTTP Method). Bottom line, our approach will have flexibility and extensibility in mind.

We also feel, that the DVR project has staled. As of 15/02/2016, the project has 10 issues open, 2 PR and the last commit was more than one month ago. 

