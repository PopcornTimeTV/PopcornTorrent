Pod::Spec.new do |s|
  s.name             = "PopcornTorrent"
  s.version          = "1.1.1.0"
  s.summary          = "Torrent client for iOS and tvOS (Used by PopcornTime)"
  s.homepage         = "https://github.com/PopcornTimeTV/PopcornTorrent"
  s.license          = 'MIT'
  s.author           = { "PopcornTime" => "popcorn@time.tv" }
  s.requires_arc = true
  #s.source =  { :git => 'https://github.com/PopcornTimeTV/PopcornTorrent.git', :tag => s.version }
  #s.source_files = 'PopcornTorrent/Source/Client/*.h'
  #s.preserve_paths = 'PopcornTorrent/Source/Client/*.m'
  s.source = { :http => "https://github.com/PopcornTimeTV/PopcornTorrent/releases/download/1.1.1.0/PopcornTorrent.framework.zip" }
  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'
  s.dependency 'GCDWebServer', '~> 3.0'
  #s.xcconfig = { 'LIBRARY_SEARCH_PATHS' => '$(PODS_ROOT)/PopcornTorrent/Source/Client/' }
  s.ios.vendored_frameworks = "Build/iOS/PopcornTorrent.framework"
  s.tvos.vendored_frameworks = "Build/tvOS/PopcornTorrent.framework"
end
