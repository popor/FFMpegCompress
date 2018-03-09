FFMpeg code copy from https://github.com/fanmaoyu0871/VideoCutterDemo

This sdk used to compress video with FFMpeg in CPU but not GPU.

------ import --------------------
if copy FFMpegCompress, you need modify list:
  1.add framwork: VideoToolbox.framework,AVFoundation.framework, libz.tdb, libbz2.tbd, libiconv.tbd
  2.Header Search Paths  :$(PROJECT_DIR)/__XXX__/FFmpeg-iOS/include

you can also use cocoapod: 
  pod 'FFMpegCompress', :git=>'https://github.com/popor/FFMpegCompress.git'

if you app have app-prefix.pch, you need modify
#ifdef __OBJC__
    #import something
#endif

------ how to use ----------------
#import <FFMpegCompress/FFMpegCompress.h>

if (!self.ffmpegCmd) {
    self.ffmpegCmd = [FFMpegCompress new];
}
                    
// local disk video url path
NSString * videoUrlPath = @"file://var/xxxxxx"; // @"var/xxxxxx";
CGSize size = CGSizeMake(540, 960);//
NSString *tPath ; // compress video save path

[self.ffmpegCmd compressVideoUrl:videoUrlPath size:size tPath:tPath finish:^(BOOL finished, NSString *info) {
    if (finished) {
        NSLog(@"FFMpegCompress finish");
        
    }else{
        NSLog(@"FFMpegCompress error: %@", info);
    }
}];