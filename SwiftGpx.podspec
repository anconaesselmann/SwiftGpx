Pod::Spec.new do |s|
  s.name             = 'SwiftGpx'
  s.version          = '1.0.1'
  s.summary          = 'SwiftGpx is a small library for reading amd writing GPX files'
  s.description      = <<-DESC
SwiftGpx is a small library for reading amd writing GPX files.
                       DESC
  s.homepage         = 'https://github.com/anconaesselmann/SwiftGpx'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'anconaesselmann' => 'axel@anconaesselmann.com' }
  s.source           = { :git => 'https://github.com/anconaesselmann/SwiftGpx.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'
  s.source_files = 'SwiftGpx/Classes/**/*'
  s.dependency 'XmlJson', '~> 1.0.1'
end
