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
  第一阶段仅包含模块骨架与 Demo，广告 SDK 按宿主是否已接入再决定是否自带。
                       DESC

  s.homepage         = 'http://gitlab.hupu.com/HPBase/lamps-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yujianchao' => 'yujianchao@hupu.com' }
  s.source           = { :git => 'git@gitlab.hupu.com:HPBase/lamps-ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'

  s.source_files = 'LampsSDK/Classes/**/*.swift'
  s.frameworks = 'Foundation', 'UIKit'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES'
  }
end
