Pod::Spec.new do |s|
  s.name             = "MDCalendarSelector"
  s.version          = "0.1.0"
  s.platform     = :ios, '8.0'
  s.summary          = "Lightweight multidate calendar selector for iOS"
  s.homepage         = "https://github.com/deirinberg/MDCalendarSelector"
  s.license          = 'MIT'
  s.author           = { "Dylan Eirinberg" => "eirinber@usc.edu" }
  s.source           = { :git => "https://github.com/deirinberg/MDCalendarSelector.git", :commit => "81c01577946215dafbc1a62d532bee68a463c566", :tag => s.version.to_s }
  s.description    = 'Easily select a range of dates in a lightweight customizable view.'
  s.source_files = 'MDCalendarSelector/*.swift'
  s.framework = 'UIKit'
  s.dependency 'PureLayout', '~> 3.0'
  s.requires_arc = true
end
