
all: iOS Mac tvOS

iOS:
	xcodebuild test -project Vinyl.xcodeproj -scheme Vinyl-iOS -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 6s' -enableCodeCoverage YES | xcpretty

Mac:
	xcodebuild test -project Vinyl.xcodeproj -scheme Vinyl-Mac | xcpretty

tvOS:
	xcodebuild test -project Vinyl.xcodeproj -scheme Vinyl-tvOS -sdk appletvsimulator -destination "platform=tvOS Simulator,name=Apple TV 1080p" | xcpretty
