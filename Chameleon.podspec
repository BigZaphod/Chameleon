Pod::Spec.new do |s|
  s.name        = "Chameleon"
  s.version     = "0.0.2"
  s.summary     = "Chameleon is a port of Apple's UIKit (and some minimal related frameworks) to Mac OS X."
  s.description = "Chameleon is a port of Apple's UIKit (and some minimal related frameworks) to Mac OS X. It is meant to be as much of a drop-in replacement for the real UIKit as possible. It also adapts some iOS user interface conventions to the Mac (such as UIAlertView being represented by NSAlert) so that apps built using Chameleon have as much chance as possible of feeling at home on the desktop with relatively little porting effort."
  s.homepage    = "http://chameleonproject.org/"
  s.author      = { "Sean Heber" => "sean@iconfactory.com" }
  s.source      = { :git => "https://github.com/michaelmelanson/Chameleon.git" }
  s.license     = { :type => 'Modified BSD License' }
  s.platform    = :osx, '10.6'
  s.frameworks  = 'IOKit', 'QuartzCore', 'SystemConfiguration', 'AppKit', 'Foundation', 'QTKit', 'WebKit'

  s.requires_arc = false
  s.compiler_flags = '-fno-objc-arc'

  s.subspec 'UIKit' do |sb|
    sb.source_files = 'UIKit/Classes/*.{h,m}'
    sb.resources    = "UIKit/Resources/*.png"
    sb.header_dir   = 'UIKit'
  end

  s.subspec 'StoreKit' do |sb|
    sb.source_files = 'StoreKit/Classes/*.{h,m}'
    sb.header_dir   = 'StoreKit'
  end

  s.subspec 'AVFoundation' do |sb|
    sb.source_files = 'AVFoundation/Classes/*.{h,m}'
    sb.header_dir   = 'AVFoundation'
  end

  s.subspec 'AssetsLibrary' do |sb|
    sb.source_files = 'AssetsLibrary/Classes/*.{h,m}'
    sb.header_dir   = 'AssetsLibrary'
  end

  s.subspec 'MediaPlayer' do |sb|
    sb.source_files = 'MediaPlayer/Classes/*.{h,m}'
    sb.header_dir   = 'MediaPlayer'
  end

  s.subspec 'MessageUI' do |sb|
    sb.source_files = 'MessageUI/*.{h,m}', 'MessageUI/Classes/*.{h,m}'
    sb.header_dir   = 'MessageUI'
  end
end
