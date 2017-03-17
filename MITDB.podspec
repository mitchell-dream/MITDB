
Pod::Spec.new do |s|
  s.name         = "MITDB"
  s.version      = "0.0.3"
  s.summary      = "MITDB summary"
  s.description  = "A tool to encapsulation of the database"
  s.homepage     = "https://github.com/mcmengchen/MITDB"
  s.license      = "MIT"
  s.author             = { "mcmengchen" => "416922992@qq.com" }
  s.social_media_url   = "http://www.jianshu.com/u/8661645b8f40"
  s.platform     = :ios, "7.0"
  s.requires_arc = true
  s.source       = { :git => "https://github.com/mcmengchen/MITDB.git", :tag => s.version.to_s }
  s.source_files = 'MITDB/Classes/**/*.{h,m,cpp,mm}'
  s.frameworks = 'UIKit','AVFoundation'
  s.dependency "YYModel"
  s.dependency "FMDBMigrationManager"
  s.dependency "FMDB/SQLCipher"

end
