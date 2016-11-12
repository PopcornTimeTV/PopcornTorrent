# PopcornTorrent for tvOS and iOS

Torrent client for tvOS and iOS implemented with `libtorrent`.

![Platform](http://img.shields.io/badge/platform-iOS%20%7C%20tvOS-lightgrey.svg?style=flat)

## Requirements

- Xcode 7.1 or greater.
- Cocoapods: `gem install cocoapods`

## Compile a new version

1. `pod install`
2. Open up \*.xcworkspace ⌘ + B in Xcode with Universal iOS scheme and Universal tvOS scheme.
3. Update the `PopcornTorrent.podspec` updating the version and linking it to the new framework version.
4. Zip the build folder
5. Push changes to github and create a new release on [GitHub](https://github.com/PopcornTimeTV/PopcornTorrent/releases), uploading the zipped build folder as a binary.
