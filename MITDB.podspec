
Pod::Spec.new do |s|
  s.name         = "MITDB"
  s.version      = "0.0.1"
  s.summary      = "MITDB summary"
  s.description  = "A tool to encapsulation of the database"
  s.homepage     = "http://EXAMPLE/MITDB"
  s.license      = "MIT"
  s.author             = { "mcmengchen" => "416922992@qq.com" }
  s.social_media_url   = "http://twitter.com/mcmengchen"
  s.platform     = :ios, "7.0"
  s.requires_arc = true
  s.source       = { :git => "http://EXAMPLE/MITDB.git", :tag => "#{s.version}" }
  s.source_files = 'MITDB/Classes/**/*.{h,m,cpp,mm}'
  s.frameworks = 'UIKit','AVFoundation'
  s.dependency "YYModel"
  s.dependency "FMDBMigrationManager"
  s.dependency "FMDB/SQLCipher"

end
