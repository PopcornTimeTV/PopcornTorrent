use_frameworks!

source 'https://github.com/CocoaPods/Specs'

def pods
    pod 'GCDWebServer', '~> 3.5.0'
end

target 'PopcornTorrent tvOS' do
    platform :tvos, '9.0'
    pods
end

target 'PopcornTorrent iOSTests' do
    platform :ios, '9.0'
    pods
end

target 'PopcornTorrent tvOSTests' do
    platform :tvos, '9.0'
    pods
end

target 'PopcornTorrent iOS' do
    platform :ios, '9.0'
    pods
end

post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['ENABLE_BITCODE'] = 'YES'
		end
	end
end
