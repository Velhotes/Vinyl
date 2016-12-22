all: iOS Mac tvOS

iOS:
	set -o pipefail && xcodebuild test -project Vinyl.xcodeproj -scheme Vinyl-iOS -destination "platform=iOS Simulator,name=iPhone 6" -enableCodeCoverage YES | xcpretty

Mac:
	set -o pipefail && xcodebuild test -project Vinyl.xcodeproj -scheme Vinyl-Mac -destination "platform=macOS" | xcpretty

tvOS:
	set -o pipefail && xcodebuild test -project Vinyl.xcodeproj -scheme Vinyl-tvOS -destination "platform=tvOS Simulator,name=Apple TV 1080p" | xcpretty
