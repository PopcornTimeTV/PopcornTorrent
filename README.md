# PopcornTorrent for tvOS and iOS

Torrent client for tvOS and iOS implemented with `libtorrent`.

![Platform](http://img.shields.io/badge/platform-iOS%20%7C%20tvOS-lightgrey.svg?style=flat)

## Requirements

- Xcode 7.1 or greater.
- Cocoapods: `gem install cocoapods`

## Compile a new version

1. `pod install`
2. Open up \*.xcworkspace ⌘ + B in Xcode with iOS scheme and then tvOS scheme (arbitrary order will suffice, just an example).
3. Locate the new \*.Framework binaries. `~/Library/Developer/Xcode/DerivedData/PopcornTorrent-*/Build/Products/` and copy them to `PopcornTorrent/PopcornTorrent/Build` inside respective folders.
4. Update the `PopcornTorrent.podspec` updating the version and linking it to the new framework version.
5. Push changes to github and create a new release on [GitHub](https://github.com/PopcornTimeTV/PopcornTorrent/releases).
