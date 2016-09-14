Pod::Spec.new do |s|
  s.name             = "PopcornTorrent"
  s.version          = "1.1.1.5"
  s.summary          = "Torrent client for iOS and tvOS (Used by PopcornTime)"
  s.homepage         = "https://github.com/PopcornTimeTV/PopcornTorrent"
  s.license          = 'MIT'
  s.author           = { "PopcornTime" => "popcorn@time.tv" }
  s.requires_arc = true
  s.source = { :git => "https://github.com/PopcornTimeTV/PopcornTorrent.git", :tag => s.version }
  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'
  s.dependency 'GCDWebServer', '~> 3.0'
  s.ios.vendored_frameworks = "PopcornTorrent/Build/iOS/PopcornTorrent.framework"
  s.tvos.vendored_frameworks = "PopcornTorrent/Build/tvOS/PopcornTorrent.framework"
end
