#!/bin/bash

pwd=`pwd`
LIPO=$(xcrun -sdk iphoneos -find lipo)
export TVOS_DEPLOYMENT_TARGET="9.0"

buildPlatform="all"
usingBitcode="YES"
cleanOutput="NO"

findLatestSDKVersion()
{
  SDKVERSION=`xcrun --sdk iphoneos --show-sdk-version`
  TVOSSDKVERSION=`xcrun --sdk appletvos --show-sdk-version`
}

xcodeBuild()
{
  if [[ $SDKVERSION < 9.0  ]]; then
    usingBitcode == "NO"
  fi

  if [[ $1 == "iphoneos" ]]; then
    archs='armv7 armv7s arm64'
  else
    archs='i386 x86_64'
  fi

  if [[ $usingBitcode == "YES" ]]; then
    xcodebuild -workspace PopcornTorrent.xcworkspace ONLY_ACTIVE_ARCH=NO VALID_ARCHS="$archs" SYMROOT="$pwd/output" -configuration Release ENABLE_BITCODE="$usingBitcode" ARCHS="$archs" OTHER_CFLAGS="-fembed-bitcode" -sdk "$1$SDKVERSION" -scheme PopcornTorrent clean build
  else
    xcodebuild -workspace PopcornTorrent.xcworkspace ONLY_ACTIVE_ARCH=NO VALID_ARCHS="$archs" SYMROOT="$pwd/output" -configuration Release ENABLE_BITCODE="$usingBitcode" ARCHS="$archs" -sdk "$1$SDKVERSION" -scheme PopcornTorrent clean build
  fi
}

buildForAllPlatform()
{
  xcodeBuild iphoneos
  xcodeBuild iphonesimulator

  mkdir -p $pwd/output/Universal

  LIPO -create $pwd/output/Release-iphoneos/libboost_system.a $pwd/output/Release-iphonesimulator/libboost_system.a -output $pwd/output/Universal/libboost_system.a
  LIPO -create $pwd/output/Release-iphoneos/libboost_filesystem.a $pwd/output/Release-iphonesimulator/libboost_filesystem.a -output $pwd/output/Universal/libboost_filesystem.a
  LIPO -create $pwd/output/Release-iphoneos/libtorrent.a $pwd/output/Release-iphonesimulator/libtorrent.a -output $pwd/output/Universal/libtorrent.a
}

xcodeBuildTVOS()
{
  if [[ $1 == "appletvos" ]]; then
    archs='arm64'
  else
    archs='x86_64'
  fi

  if [[ $usingBitcode == "YES" ]]; then
    xcodebuild -workspace PopcornTorrent.xcworkspace ONLY_ACTIVE_ARCH=NO VALID_ARCHS="$archs" SYMROOT="$pwd/output" -configuration Release ENABLE_BITCODE="$usingBitcode" ARCHS="$archs" OTHER_CFLAGS="-fembed-bitcode" -sdk "$1$TVOSSDKVERSION" -scheme PopcornTorrent clean build
  else
    xcodebuild -workspace PopcornTorrent.xcworkspace ONLY_ACTIVE_ARCH=NO VALID_ARCHS="$archs" SYMROOT="$pwd/output" -configuration Release ENABLE_BITCODE="$usingBitcode" ARCHS="$archs" -sdk "$1$TVOSSDKVERSION" -scheme PopcornTorrent clean build
  fi
}

buildTVDynamic()
{
    xcodebuild -workspace PopcornTorrent.xcworkspace ONLY_ACTIVE_ARCH=NO SYMROOT="$pwd/output" -configuration Release ENABLE_BITCODE="$usingBitcode" -scheme PopcornTorrent clean build
}

buildFatForTVOS()
{
  xcodeBuildTVOS appletvos
  xcodeBuildTVOS appletvsimulator

  mkdir -p $pwd/output/UniversalTVOS

  LIPO -create $pwd/output/Release-appletvos/libboost_system.a $pwd/output/Release-appletvsimulator/libboost_system.a -output $pwd/output/UniversalTVOS/libboost_system.a
  LIPO -create $pwd/output/Release-appletvos/libboost_filesystem.a $pwd/output/Release-appletvsimulator/libboost_filesystem.a -output $pwd/output/UniversalTVOS/libboost_filesystem.a
  LIPO -create $pwd/output/Release-appletvos/libtorrent.a $pwd/output/Release-appletvsimulator/libtorrent.a -output $pwd/output/UniversalTVOS/libtorrent.a
}

findLatestSDKVersion

for i in "$@"
do
  case $i in
    -p=*|--platform=*)
    buildPlatform="${i#*=}"
    shift
    ;;
    -b=*|--bitcode=*)
    usingBitcode="${i#*=}"
    shift
    ;;
    -c|--clean)
    cleanOutput="YES"
    shift
    ;;
    *)

    ;;
  esac
done

if [[ $cleanOutput == "NO" ]]; then
  if [[ usingBitcode -ne "YES" && usingBitcode -ne "NO" ]]; then
    usingBitcode="YES"
  fi

  echo "Using bitcode: $usingBitcode"
  echo "Platform: $buildPlatform"

  if [[ $buildPlatform == "all" ]]; then
    buildForAllPlatform
  elif [[ $buildPlatform == "device" ]]; then
    xcodeBuild iphoneos
  elif [[ $buildPlatform == "simulator" ]]; then
    xcodeBuild iphonesimulator
  elif [[ $buildPlatform == "tvosdevice" ]]; then
    xcodeBuildTVOS appletvos
  elif [[ $buildPlatform == "tvossimulator" ]]; then
    xcodeBuildTVOS appletvsimulator
  elif [[ $buildPlatform == "tvosall" ]]; then
    buildFatForTVOS
  elif [[ $buildPlatform == "tvdynamic" ]]; then
    buildTVDynamic
  else
    buildForAllPlatform
  fi
else
  `rm -rf $pwd/output`
  echo "Output folder cleaned!"
fi
