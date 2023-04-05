#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint aws_integration_test.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'aws_integration_test'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin which helps running integration tests on AWS device farm'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://gostudent.org'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'GoStudent.org' => 'mazen.bilbiesi@gostudent.org' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.weak_framework = 'XCTest'
  s.ios.framework  = 'UIKit'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }

  s.swift_version = '5.0'
  s.dependency 'Telegraph', '~> 0.30.0'
  s.dependency 'Alamofire', '~> 5.6.4'
end
