#
# Be sure to run `pod lib lint BOCeRouter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BOCeRouter'
  s.version          = '0.0.2'
  s.summary          = 'zhangwenxue'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "A Router for BOCE P2C"

  s.homepage         = 'https://github.com/guang1472006/BOCeRouter.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zhangwenxue' => '734781246@qq.com' }
  s.source           = { :git => 'https://github.com/guang1472006/BOCeRouter.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'BOCeRouter/Classes/*'
  
  # s.resource_bundles = {
  #   'BOCeRouter' => ['BOCeRouter/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  # logger
  s.subspec 'BOCeRouterLogger' do | logger |
  logger.source_files = 'BOCeRouter/Classes/BOCeRouterLogger/*.{h,m}'
  end
  
  # Navigation
  s.subspec 'BOCeRouterNavigation' do | navigation |
  navigation.source_files = 'BOCeRouter/Classes/BOCeRouterNavigation/*.{h,m}'
  end
  
  # rewrite
  s.subspec 'BOCeRouterRewrite' do | rewrite |
  rewrite.source_files = 'BOCeRouter/BOCeRouterRewrite/*.{h,m}'
  end
  
  
  
  
end
