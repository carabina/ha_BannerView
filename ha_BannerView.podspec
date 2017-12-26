
Pod::Spec.new do |s|

  s.name         = "ha_BannerView"
  s.version      = "0.0.1"
  s.summary      = "a simple banner view for ios ."

  # s.description  = <<-DESC
  #                  DESC

  s.homepage     = "https://github.com/hahand/ha_BannerView"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "hahand" => "hahand@yeah.net" }

  s.ios.deployment_target = "8.0"

  s.source       = { :git => "https://github.com/hahand/ha_BannerView.git", :tag => "#{s.version}" }

  s.source_files  = "ha_BannerViewDemo/ha_BannerView", "ha_BannerView/**/*.{h,m}"

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"
  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
