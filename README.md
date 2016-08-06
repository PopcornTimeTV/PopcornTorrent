# PopcornTorrent for tvOS

Torrent client for tvOS implemented with `libtorrent`.

[![Build Status](https://travis-ci.org/PopcornTimeTV/PopcornTorrent.svg?branch=master)](https://travis-ci.org/PopcornTimeTV/PopcornTorrent)
[![Carthage Compatible](https://img.shields.io/badge/Carthage|CocoaPods-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![platform](https://img.shields.io/badge/Platform-tvOS-lightgrey.svg)

## Requirements

- Xcode 7.1
- Carthage: `brew install carthage`
- Cocoapods: `gem install cocoapods`

## Compile a new version

1. Make sure you have static libraries compiled. They can be compiled with `sh build.sh -p=tvosall`
2. Compile the dynamic framework `PopcornTorrent` with `carthage build --no-skip-current --platform tvos`
3. Archive the framework using `carthage archive PopcornTorrent`
4. Create a new release on [GitHub](https://github.com/PopcornTimeTV/PopcornTorrent/releases) uploading the Framework.
5. Update the `PopcornTorrent.podspec` updating the version and linking it to the new framework version.
6. Push the new version to the private specs repository with: `pod repo push PopcornTimeTV PopcornTorrent.podspec  --verbose --allow-warnings`

## Building static libraries

PopcornTorrent is distributed using CocoaPods and it has internal static libraries as dependencies in `Libtorrent` *(static library)*. These static libraries can be build using the `build.sh` script in the root directory:

```bash
sh build.sh -b=NO # Without bitcode support run build script with -b/--bitcode=NO|YES flag
sh build.sh -p=device # Only for specefied platform run build script with -p/--platform=all|device|simulator
sh build.sh -c # For cleaning buid directory run script
sh build.sh -p=tvosdevice # Build for tvOS
sh build.sh -p=tvosdevice # Build for tvOS (Device)
sh build.sh -p=tvossimulator # Build for tvOS (Simulator)
sh build.sh -p=tvosall # Build for tvOS (Simulator/Device)
```
