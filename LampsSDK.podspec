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
  支持源码 / 二进制两种分发；广告 SDK 通过 CSJ / GDT / Noah Subspec 按需拉取。
                       DESC

  s.homepage         = 'http://gitlab.hupu.com/HPBase/lamps-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yujianchao' => 'yujianchao@hupu.com' }
  s.source           = { :git => 'git@gitlab.hupu.com:HPBase/lamps-ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'
  s.default_subspecs = 'Core', 'CSJ', 'GDT', 'Noah'

  # true = LampsSDK/Binary xcframework；false = Classes 源码。切换后宿主需 pod install。
  # 二进制请先执行 ./scripts/build_xcframeworks.sh（会同步到 Binary/）。
  use_binary = false

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES'
  }

  binary_adapter_xcconfig = {
    'OTHER_LDFLAGS' => '$(inherited) -ObjC'
  }

  s.subspec 'Core' do |ss|
    if use_binary
      ss.vendored_frameworks = 'LampsSDK/Binary/LampsSDK.xcframework'
    else
      ss.source_files = [
        'LampsSDK/Classes/Public/**/*.swift',
        'LampsSDK/Classes/Core/**/*.swift',
        'LampsSDK/Classes/Config/**/*.swift',
        'LampsSDK/Classes/Web/**/*.swift',
        'LampsSDK/Classes/Report/**/*.swift',
        'LampsSDK/Classes/Reward/*.swift',
        'LampsSDK/Classes/Adapter/*.swift'
      ]
    end
    ss.frameworks = 'Foundation', 'UIKit', 'WebKit', 'AdSupport', 'SystemConfiguration', 'CoreTelephony'
    ss.weak_frameworks = 'AppTrackingTransparency'
    ss.libraries = 'z'
  end

  s.subspec 'CSJAdapter' do |ss|
    ss.dependency 'LampsSDK/Core'
    # 不声明 Ads-CN：供「宿主已本地/其它 Pod 集成穿山甲」场景。
    # 源码模式无条件 import BUAdSDK：宿主须 post_install 挂 FRAMEWORK_SEARCH_PATHS，
    # 或缺配置立刻编译失败；也可改用 CSJ Subspec 由 Lamps 自行拉依赖。
    if use_binary
      ss.vendored_frameworks = 'LampsSDK/Binary/Adapters/LampsCSJAdapter.xcframework'
      ss.pod_target_xcconfig = binary_adapter_xcconfig
    else
      ss.source_files = 'LampsSDK/Classes/CSJAdapter/**/*.{swift,m,h}'
    end
  end

  s.subspec 'GDTAdapter' do |ss|
    ss.dependency 'LampsSDK/Core'
    # 同 CSJAdapter：不声明 GDTMobSDK；源码无条件 import，须宿主挂路径或改用 GDT。
    if use_binary
      ss.vendored_frameworks = 'LampsSDK/Binary/Adapters/LampsGDTAdapter.xcframework'
      ss.pod_target_xcconfig = binary_adapter_xcconfig
    else
      ss.source_files = 'LampsSDK/Classes/GDTAdapter/**/*.{swift,m,h}'
    end
  end

  s.subspec 'NoahAdapter' do |ss|
    ss.dependency 'LampsSDK/Core'
    # 同 CSJAdapter：不声明 Noah；源码无条件 import，须宿主挂路径或改用 Noah。
    if use_binary
      ss.vendored_frameworks = 'LampsSDK/Binary/Adapters/LampsNoahAdapter.xcframework'
      ss.pod_target_xcconfig = binary_adapter_xcconfig
    else
      ss.source_files = 'LampsSDK/Classes/NoahAdapter/**/*.{swift,m,h}'
    end
  end

  s.subspec 'CSJ' do |ss|
    ss.dependency 'LampsSDK/CSJAdapter'
    ss.dependency 'Ads-CN/BUAdSDK'
  end

  s.subspec 'GDT' do |ss|
    ss.dependency 'LampsSDK/GDTAdapter'
    ss.dependency 'GDTMobSDK'
  end

  # 汇川：自带官方二进制（方案 B），不依赖私有 NoahAdSdks
  s.subspec 'Noah' do |ss|
    ss.dependency 'LampsSDK/NoahAdapter'
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

  # DevTools：Lamps 状态页 + 穿山甲 / 优量汇调试依赖；汇川工具已在 NoahSDK 内。
  # 不进入 default_subspecs。
  # 源码请用独立 pod `LampsDevTools`（模块名 LampsDevTools，与二进制 import 一致）。
  # 本 subspec 仅二进制快捷方式：引入 LampsDevTools.xcframework。
  s.subspec 'DevTools' do |ss|
    ss.dependency 'LampsSDK/Core'
    ss.dependency 'GDTDevToolSDK'
    ss.dependency 'Ads-CN/BUAdTestMeasurement'
    if use_binary
      ss.vendored_frameworks = 'LampsSDK/Binary/DevTools/LampsDevTools.xcframework'
      ss.pod_target_xcconfig = {
        'OTHER_LDFLAGS' => '$(inherited) -ObjC'
      }
    else
      ss.source_files = 'LampsSDK/Classes/Debug/**/*.{swift,m,h}'
    end
  end
end
