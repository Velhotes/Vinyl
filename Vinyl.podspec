Pod::Spec.new do |s|
  s.name         = "Vinyl"
  s.version      = "0.10.4"
  s.summary      = "Network testing à la VCR in Swift"
  s.description  = "Vinyl is a simple, yet flexible library used for replaying HTTP requests while unit testing. It takes heavy inspiration from DVR and VCR."
  s.homepage     = "https://github.com/Velhotes/Vinyl"
  s.author       = { 'Velhotes' => '(email)' }
  s.license      = 'MIT'
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '9.1'
  s.source       = { :git => "https://github.com/Velhotes/Vinyl.git", :tag => s.version }
  s.source_files = "Vinyl/**/*.swift"
end
