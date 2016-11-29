Pod::Spec.new do |spec|
  spec.name         = "TokenField"
  spec.version      = "0.1.0"
  spec.platform     = :ios, "8.0"
  spec.license      = { :type => "MIT" }
  spec.homepage     = "https://github.com/rchatham/TokenField"
  spec.authors      = { "Reid Chatham" => "reid.chatham@gmail.com" }
  spec.summary      = "Token Field in Swift inspired by VENTokenField."
  spec.source       = { :git => "https://github.com/rchatham/TokenField.git", :tag => "#{spec.version}" }
  spec.source_files = "TokenField/*"
end
