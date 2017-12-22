Pod::Spec.new do |s|
  s.name             = 'PDFSlideView'
  s.version          = '0.1.0'
  s.summary          = 'A short description of PDFSlideView.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/abeyuya/PDFSlideView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'abeyuya' => 'yuya.abe.0525@gmail.com' }
  s.source           = { :git => 'https://github.com/abeyuya/PDFSlideView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.source_files = 'PDFSlideView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'PDFSlideView' => ['PDFSlideView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'PDFKit'
  s.dependency 'ReSwift'
end
