Pod::Spec.new do |s|
  s.name             = 'LampsDevTools'
  s.version          = '0.1.0'
  s.summary          = 'LampsSDK 调试工具（独立模块，供 xcframework 出包）'
  s.homepage         = 'http://gitlab.hupu.com/HPBase/lamps-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yujianchao' => 'yujianchao@hupu.com' }
  s.source           = { :git => 'git@gitlab.hupu.com:HPBase/lamps-ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'
  s.static_framework = true

  s.dependency 'LampsSDK/Core', s.version.to_s
  s.dependency 'GDTDevToolSDK'
  s.dependency 'Ads-CN/BUAdTestMeasurement'

  # 汇川调试页不在此声明 NoahSDK：运行时 NSClassFromString，宿主链了 Noah 即可用。

  s.source_files = 'LampsSDK/Classes/Debug/**/*.{swift,m,h}'
  s.private_header_files = 'LampsSDK/Classes/Debug/**/*.h'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES',
    'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => '$(inherited) LampsADAPTER_SEPARATE_MODULE'
  }
end
