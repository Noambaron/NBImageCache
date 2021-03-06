#
# Be sure to run `pod lib lint NBImageCache.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "NBImageCache"
  s.version          = "0.1.0"
  s.summary          = "Fast and asynchronous image cache, based on Realm.io and with a simple block based api."
# s.description      = <<-DESC DESC
  s.homepage         = "https://github.com/Noambaron/NBImageCache"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Noam Bar-on" => "bar.on.noam1@gmail.com" }
  s.source           = { :git => "https://github.com/Noambaron/NBImageCache.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://www.linkedin.com/in/noambaron'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'NBImageCache' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
    s.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
  # s.dependency 'AFNetworking', '~> 2.3'
    s.dependency 'Realm', '~> 0.91.1'

end
