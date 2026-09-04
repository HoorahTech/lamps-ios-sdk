Pod::Spec.new do |s|
  s.name             = 'LampsGDTAdapter'
  s.version          = '0.0.2'
  s.summary          = 'LampsSDK 优量汇激励 Adapter（独立模块，供 xcframework 出包）'
  s.homepage         = 'http://gitlab.hupu.com/HPBase/lamps-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yujianchao' => 'yujianchao@hupu.com' }
  s.source           = { :git => 'git@gitlab.hupu.com:HPBase/lamps-ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'
  s.static_framework = true

  s.dependency 'LampsSDK/Core', s.version.to_s
  s.dependency 'GDTMobSDK'

  s.source_files = 'LampsSDK/Classes/GDTAdapter/**/*.{swift,m,h}'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES',
    'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => '$(inherited) LampsADAPTER_SEPARATE_MODULE'
  }
end
