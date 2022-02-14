# Uncomment the next line to define a global platform for your project
platform :ios, '12.1'

target 'sessions' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for sessions
    # Pods for CocoMediaSDK
    pod 'SwiftLint'
    pod 'SwiftFormat/CLI'
    pod 'CocoaLumberjack/Swift'
    pod 'CocoMediaPlayer' , :path => "~/Workspace/cocomediaplayer-swift"
    pod 'CocoMediaSDK' , :path => "~/Workspace/cocomediasdk-swift"
    pod 'AlamofireImage'
    pod 'AMRAudioSwift'
    pod 'SwiftyJSON'

  target 'sessionsTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'sessionsUITests' do
    # Pods for testing
  end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      end
    end
  end
  
end
