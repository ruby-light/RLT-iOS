Pod::Spec.new do |s|
  s.name                   = "RLT-iOS"
  s.version                = "1.0.2"
  s.summary                = "Native iOS SDK."
  s.homepage               = "https://github.com/ruby-light/RLT-iOS"
  s.author                 = "Alexey Chirkov"
  s.source                 = { :git => "git@github.com:ruby-light/RLT-iOS.git", :tag => "#{s.version}" }
  s.ios.deployment_target  = '8.0'
  s.source_files           = "RLT-iOS/RLT-iOS/**/*.{h,m}"
  s.requires_arc           = true
  s.library 	           = 'sqlite3.0'
end
