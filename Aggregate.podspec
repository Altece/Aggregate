#
# Be sure to run `pod lib lint Aggregate.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
  s.name             = 'Aggregate'
  s.version          = '1.0.0'
  s.summary          = 'An aggregating object which can compose protocol implementations from various objects.'

  s.description      = <<-DESC
An aggregating object which can compose protocol implementations from various objects
This can be useful for dividing large protocol implementations into separate objects,
and then combining them here to pass to a client as a single delegate, data source, or object.
                       DESC

  s.homepage         = 'https://github.com/altece/Aggregate'
  s.license          = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author           = { 'Steven Brunwasser' => '' }
  s.source           = { :git => 'https://github.com/altece/Aggregate.git', :tag => s.version.to_s }

  s.platforms = { :ios => '8.0', :osx => '10.9', :watchos => '2.0', :tvos => '9.0' }

  s.source_files = 'Aggregate/**/*.{h,m,swift}'
end
