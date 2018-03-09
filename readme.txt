FFMpeg code copy from https://github.com/fanmaoyu0871/VideoCutterDemo



if copy FFMpeg, you need modify list:
  1.add framwork: VideoToolbox.framework,AVFoundation.framework, libz.tdb, libbz2.tbd, libiconv.tbd
  2.Header Search Paths  :$(PROJECT_DIR)/__XXX__/FFmpeg-iOS/include

you also can use cocoapod: 
  pod 'FFMpeg_iOS_SDK', :git=>'https://github.com/popor/FFMpeg_iOS_SDK.git'

if you app have app-prefix.pch, you need modify
#ifdef __OBJC__
    #import something
#endif