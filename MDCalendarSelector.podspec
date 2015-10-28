Pod::Spec.new do |s|
  s.name             = "MDCalendarSelector"
  s.version          = "0.1.0"
  s.summary          = "Lightweight multidate calendar selector for iOS"
  s.description      = <<-DESC
                       Easily select a range of dates in a lightweight easy to customize view.
                       DESC
  s.homepage         = "https://github.com/deirinberg/MDCalendarSelector"
  s.license          = 'MIT'
  s.author           = { "Dylan Eirinberg" => "eirinber@usc.edu" }
  s.source           = { :git => "https://github.com/deirinberg/MDCalendarSelector.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/*.{swift}'
  s.resource_bundles = {
    'MDCalendarSelector' => ['Pod/Assets/*.png']
  }
  s.frameworks = 'UIKit'
  s.dependency 'PureLayout', '~> 3.0'
end
