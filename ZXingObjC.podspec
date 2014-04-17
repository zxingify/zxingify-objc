Pod::Spec.new do |s|
  s.name                        = "ZXingObjC"
  s.version                     = "2.4.0-alpha.1"
  s.summary                     = "An Objective-C Port of ZXing."
  s.homepage                    = "https://github.com/TheLevelUp/ZXingObjC"
  s.author                      = "ZXing team (http://code.google.com/p/zxing/people/list) and TheLevelUp"

  s.license                     = { :type => 'Apache License 2.0', :file => 'COPYING' }

  s.source                      = { :git => "https://github.com/TheLevelUp/ZXingObjC.git", :tag => "2.4.0-alpha.1" }
  s.ios.deployment_target 	= '5.0'
  s.osx.deployment_target 	= '10.7'

  s.requires_arc                = true

  s.frameworks                  = 'ImageIO', 'CoreGraphics', 'CoreVideo', 'CoreMedia', 'QuartzCore', 'AVFoundation', 'AudioToolbox'

  s.default_subspec             = 'Core'

  # s.subspec 'ZXingObjC' do |spec|
  #   spec.dependency 'ZXingObjC/Aztec'
  #   spec.dependency 'ZXingObjC/Core'
  #   spec.dependency 'ZXingObjC/DataMatrix'
  #   spec.dependency 'ZXingObjC/MaxiCode'
  #   spec.dependency 'ZXingObjC/OneD'
  #   spec.dependency 'ZXingObjC/PDF417'
  #   spec.dependency 'ZXingObjC/QRCode'
  #   spec.dependency 'ZXingObjC/ResultParsers'
  #   spec.source_files = 'ZXingObjC/*.{h,m}'
  # end

  s.subspec 'Core' do |spec|
    spec.source_files = 'ZXingObjC/client/*.{h,m}', 'ZXingObjC/common/**/*.{h,m}',
      'ZXingObjC/core/*.{h,m}', 'ZXingObjC/multi/*.{h,m}'
  end

  # s.subspec 'Aztec' do |spec|
  #   spec.dependency 'ZXingObjC/Core'
  #   spec.source_files = 'ZXingObjC/aztec/**/*.{h,m}'
  # end

  # s.subspec 'DataMatrix' do |spec|
  #   spec.dependency 'ZXingObjC/Core'
  #   spec.source_files = 'ZXingObjC/datamatrix/**/*.{h,m}'
  # end

  # s.subspec 'MaxiCode' do |spec|
  #   spec.dependency 'ZXingObjC/Core'
  #   spec.source_files = 'ZXingObjC/maxicode/**/*.{h,m}'
  # end

  # s.subspec 'OneD' do |spec|
  #   spec.dependency 'ZXingObjC/Core'
  #   spec.source_files = 'ZXingObjC/oned/**/*.{h,m}'
  # end

  # s.subspec 'PDF417' do |spec|
  #   spec.dependency 'ZXingObjC/Core'
  #   spec.source_files = 'ZXingObjC/pdf417/**/*.{h,m}'
  # end

  # s.subspec 'QRCode' do |spec|
  #   spec.dependency 'ZXingObjC/Core'
  #   spec.source_files = 'ZXingObjC/qrcode/**/*.{h,m}', 'ZXingObjC/multi/qrcode/**/*.{h,m}'
  # end

  # s.subspec 'ResultParsers' do |spec|
  #   spec.dependency 'ZXingObjC/Core'
  #   spec.source_files = 'ZXingObjC/client/result/**/*.{h,m}'
  # end
end
