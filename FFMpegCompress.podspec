#
#  Be sure to run `pod spec lint FFMpegCompress.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

s.name         = "FFMpegCompress"
s.version      = "0.0.24"
s.summary      = "FFMpegCompress contain a available FFMpeg SDK for OC"

s.homepage     = "https://github.com/popor/FFMpegCompress"
s.license      = "MIT"

s.author       = { "wangkq" => "908891024@qq.com" }
s.platform     = :ios
s.platform     = :ios, "5.0"
s.source       = { :git => "https://github.com/popor/FFMpegCompress.git", :tag => s.version }

s.source_files  =  "*.{h,m}"

# ――― Project Linking ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# s.framework  = "SomeFramework"
s.frameworks = "VideoToolbox", "AVFoundation"

# s.library   = "iconv"
s.libraries = "z", "bz2", "iconv"

# arc 设置,c语言无所谓.
# s.requires_arc = true

# 这里是工程配置，这样使用者就不需要手动处理，由pod自动处理了。但是不是本pod配置文件
#s.xcconfig = { 'USER_HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/FFMpegCompress/FFmpegSDK/include' } # ok的,可以直接引用了
s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/FFMpegCompress/FFmpegSDK/include' } # ok的,可以直接引用了

# 这里可以配置.a文件
s.vendored_libraries = 'FFmpegSDK/lib/*.a'


# ――― Folder ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
s.subspec 'FFmpegSDK' do |fsdk|
fsdk.source_files = 'FFmpegSDK/*.{h,c}'

# 第一个文件夹
fsdk.subspec 'lib' do |lib|
lib.source_files = 'FFmpegSDK/lib/*.a'
end

# 第二个文件夹
fsdk.subspec 'include' do |include|
# 子1
include.subspec 'libavcodec' do |libavcodec|
libavcodec.source_files = 'FFmpegSDK/include/libavcodec/*.h'
end

# 子2
include.subspec 'libavdevice' do |libavdevice|
libavdevice.source_files = 'FFmpegSDK/include/libavdevice/*.h'
end

# 子3
include.subspec 'libavfilter' do |libavfilter|
libavfilter.source_files = 'FFmpegSDK/include/libavfilter/*.h'
end

# 子4
include.subspec 'libavformat' do |libavformat|
libavformat.source_files = 'FFmpegSDK/include/libavformat/*.h'
end

# 子5
include.subspec 'libavutil' do |libavutil|
libavutil.source_files = 'FFmpegSDK/include/libavutil/*.h'
end

# 子6
include.subspec 'libswresample' do |libswresample|
libswresample.source_files = 'FFmpegSDK/include/libswresample/*.h'
end

# 子7
include.subspec 'libswscale' do |libswscale|
libswscale.source_files = 'FFmpegSDK/include/libswscale/*.h'
end

end
end


# 完毕
end

