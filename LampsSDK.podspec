#
# Be sure to run `pod lib lint LampsSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LampsSDK'
  s.version          = '0.1.0'
  s.summary          = 'WebView、Bridge、激励视频与监测上报 SDK'

  s.description      = <<-DESC
  LampsSDK 面向三方 App，提供 WebView 展示与 Bridge 通信、激励视频、CM/PM/XM 监测上报。
  默认包含 Core 与各渠道 Adapter 源码；广告 SDK 二进制通过 CSJ / GDT / Noah Subspec 按需拉取。
                       DESC

  s.homepage         = 'http://gitlab.hupu.com/HPBase/lamps-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yujianchao' => 'yujianchao@hupu.com' }
  s.source           = { :git => 'git@gitlab.hupu.com:HPBase/lamps-ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'
  s.default_subspecs = 'Core', 'CSJ', 'GDT', 'Noah'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES'
  }

  s.subspec 'Core' do |ss|
    ss.source_files = [
      'LampsSDK/Classes/Public/**/*.swift',
      'LampsSDK/Classes/Core/**/*.swift',
      'LampsSDK/Classes/Config/**/*.swift',
      'LampsSDK/Classes/Web/**/*.swift',
      'LampsSDK/Classes/Report/**/*.swift',
      'LampsSDK/Classes/Reward/*.swift',
      'LampsSDK/Classes/Adapter/*.swift'
    ]
    ss.frameworks = 'Foundation', 'UIKit', 'WebKit', 'AdSupport'
    ss.weak_frameworks = 'AppTrackingTransparency'
  end

  # 渠道包：Initializer + RewardAdapter 平铺在同目录，Pods 展示更干净
  s.subspec 'CSJAdapter' do |ss|
    ss.dependency 'LampsSDK/Core'
    ss.source_files = 'LampsSDK/Classes/CSJAdapter/**/*.{swift,m,h}'
  end

  s.subspec 'GDTAdapter' do |ss|
    ss.dependency 'LampsSDK/Core'
    ss.source_files = 'LampsSDK/Classes/GDTAdapter/**/*.{swift,m,h}'
  end

  s.subspec 'NoahAdapter' do |ss|
    ss.dependency 'LampsSDK/Core'
    ss.source_files = 'LampsSDK/Classes/NoahAdapter/**/*.{swift,m,h}'
  end

  s.subspec 'CSJ' do |ss|
    ss.dependency 'LampsSDK/CSJAdapter'
    ss.dependency 'Ads-CN'
  end

  s.subspec 'GDT' do |ss|
    ss.dependency 'LampsSDK/GDTAdapter'
    ss.dependency 'GDTMobSDK'
  end

  # 汇川：自带官方二进制（方案 B），不依赖私有 NoahAdSdks
  s.subspec 'Noah' do |ss|
    ss.dependency 'LampsSDK/NoahAdapter'
    # NoahSDK 运行时依赖（与 NoahAdSdks 一致）
    ss.dependency 'AFNetworking'
    ss.dependency 'SDWebImage'
    ss.dependency 'YYModel'
    ss.vendored_frameworks = [
      'LampsSDK/Vendor/Noah/NoahSDK.framework',
      'LampsSDK/Vendor/Noah/Other/*.framework'
    ]
    ss.resources = [
      'LampsSDK/Vendor/Noah/NoahSDK.framework/*.bundle',
      'LampsSDK/Vendor/Noah/Other/**/*.bundle'
    ]
    ss.frameworks = 'CoreTelephony', 'SystemConfiguration', 'WebKit', 'ImageIO', 'Accelerate',
                    'CoreServices', 'AVKit', 'CoreData', 'Security', 'CoreGraphics',
                    'MobileCoreServices', 'MessageUI', 'SafariServices', 'StoreKit',
                    'AVFoundation', 'MediaPlayer', 'JavaScriptCore', 'QuickLook',
                    'CoreMotion', 'CoreMedia', 'CoreLocation', 'MapKit', 'AdSupport'
    ss.weak_frameworks = 'AppTrackingTransparency', 'DeviceCheck'
    ss.libraries = 'c++abi', 'sqlite3', 'c++', 'xml2', 'resolv', 'z'
    ss.pod_target_xcconfig = {
      'OTHER_LDFLAGS' => '$(inherited) -ObjC'
    }
  end

  s.subspec 'Ads' do |ss|
    ss.dependency 'LampsSDK/CSJ'
    ss.dependency 'LampsSDK/GDT'
    ss.dependency 'LampsSDK/Noah'
  end
end
