#
# Be sure to run `pod lib lint CognitoWrapper.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CognitoWrapper'
  s.version          = '0.1.0'
  s.summary          = 'A wrapper around AWS Cognito SDK'
  s.platform         = :ios, '11.0'
  s.swift_version    = '4.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This pod provides a simple API for logging in to an AWS backend using Cognito User Pools.
                       DESC

  s.homepage         = 'https://github.com/aldo-dev/CognitoWrapper'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'egarro@aldogroup.com' => 'egarro@aldogroup.com' }
  s.source           = { :git => 'https://github.com/aldo-dev/CognitoWrapper.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.3'
  s.source_files = 'CognitoWrapper/Classes/**/*'
  
  # s.resource_bundles = {
  #   'CognitoWrapper' => ['CognitoWrapper/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AWSCognito'
  s.dependency 'AWSCognitoAuth'
  s.dependency 'AWSCognitoIdentityProvider'
  s.dependency 'AWSUserPoolsSignIn'
  s.dependency 'EitherResult'

end
