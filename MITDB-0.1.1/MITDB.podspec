Pod::Spec.new do |s|
  s.name = "MITDB"
  s.version = "0.1.1"
  s.summary = "MITDB summary"
  s.license = "MIT"
  s.authors = {"mcmengchen"=>"416922992@qq.com"}
  s.homepage = "https://github.com/mcmengchen/MITDB"
  s.description = "A tool to encapsulation of the database"
  s.social_media_url = "http://www.jianshu.com/u/8661645b8f40"
  s.frameworks = ["UIKit", "AVFoundation"]
  s.requires_arc = true
  s.source = { :path => '.' }

  s.ios.deployment_target    = '7.0'
  s.ios.vendored_framework   = 'ios/MITDB.framework'
end
