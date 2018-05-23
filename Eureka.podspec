Pod::Spec.new do |s|
  s.name = 'Eureka'
  s.version = '4.0.0'
  s.license = 'MIT'
  s.summary = 'Elegant iOS Forms in pure Swift'
  s.homepage = 'https://github.com/xmartlabs/Eureka'
  s.social_media_url = 'http://twitter.com/xmartlabs'
  s.authors = { 'Martin Barreto' => 'martin@xmartlabs.com', 'Mathias Claassen' => 'mathias@xmartlabs.com' }
  s.source = { :git => 'https://github.com/xmartlabs/Eureka.git', :tag => s.version }
  s.ios.deployment_target = '8.0'
  s.ios.frameworks = 'UIKit', 'Foundation'
  s.source_files = 'Source/**/*.swift'
  s.resources = 'Source/Resources/Eureka.bundle'
  s.requires_arc = true
end
