Pod::Spec.new do |s|
  s.name             = 'LampsAlipayAdapter'
  s.version          = '1.0.4'
  s.summary          = 'LampsSDK 支付宝支付 Adapter（独立模块，供 xcframework 出包）'
  s.homepage         = 'http://gitlab.hupu.com/HPBase/lamps-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yujianchao' => 'yujianchao@hupu.com' }
  s.source           = { :git => 'git@gitlab.hupu.com:HPBase/lamps-ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'
  s.static_framework = true

  s.dependency 'LampsSDK/Core', s.version.to_s
  # 仅出包编译期可见。不要打进 Adapter xcframework。
  # 宿主集成用 LampsSDK/AlipayAdapter，那个 subspec 不依赖 AlipaySDK-iOS。
  s.dependency 'AlipaySDK-iOS'

  s.source_files = 'LampsSDK/Classes/AlipayAdapter/*.{swift,m,h}'
  # 同 LampsSDK/AlipayAdapter：:git 安装会清掉未声明的 Module，须保留才能 import AlipaySDK。
  s.preserve_paths = 'LampsSDK/Classes/AlipayAdapter/Module/*'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES',
    'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => '$(inherited) LampsADAPTER_SEPARATE_MODULE',
    # 支付宝 framework 没有 module map，用仓库里的同名 module 才能 import AlipaySDK。
    'SWIFT_INCLUDE_PATHS' => '$(inherited) $(PODS_TARGET_SRCROOT)/LampsSDK/Classes/AlipayAdapter/Module',
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "${PODS_ROOT}/AlipaySDK-iOS" "${PODS_XCFRAMEWORKS_BUILD_DIR}/AlipaySDK-iOS"'
  }
end
