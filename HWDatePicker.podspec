#
# Be sure to run `pod lib lint HWDatePicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HWDatePicker'
  s.version          = '1.0.0'
  s.summary          = '可自定义格式的日期选择控件'
  s.homepage         = 'https://github.com/wanghouwen/HWDatePicker'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wanghouwen' => 'wanghouwen123@126.com' }
  s.source           = { :git => 'https://github.com/wanghouwen/HWDatePicker.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  s.requires_arc = true
  s.ios.deployment_target = '8.0'

  s.source_files = 'HWDatePicker/*.{h,m}'
  s.public_header_files = 'HWDatePicker/*.h'
  s.dependency 'HWExtension/Category'
  
  # s.frameworks = 'UIKit', 'MapKit'
  
end
