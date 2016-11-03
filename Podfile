source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'
use_frameworks!

target 'PhiFactor' do
    pod 'AWSS3', '~> 2.4.1'
    pod 'Alamofire', '~> 3.4'
    pod 'DeviceKit', '~> 0.3.2'
    pod 'GoogleAnalytics', '~> 3.14'
end
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3'
        end
    end
end
