//
//  FFMpegCompress.m
//

#import "FFMpegCompress.h"

#import "ffmpeg.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

static NSString * ThreadCompressName = @"FFMpegCompressVideo";

@implementation FFMpegCompress

// test code.
//CGSize tSize =  CGSizeMake(50, 40);
//NSLog(@"100*100_%i*%i ==> size: %@", (int)tSize.width, (int)tSize
//      .height, NSStringFromCGSize([FFMpegCmd sizeFrom:CGSizeMake(100, 100) targetSize:tSize]));
//NSLog(@"80*60  _%i*%i ==> size: %@", (int)tSize.width, (int)tSize
//      .height, NSStringFromCGSize([FFMpegCmd sizeFrom:CGSizeMake(80, 60) targetSize:tSize]));
//NSLog(@"60*80  _%i*%i ==> size: %@", (int)tSize.width, (int)tSize
//      .height, NSStringFromCGSize([FFMpegCmd sizeFrom:CGSizeMake(60, 80) targetSize:tSize]));
//
//NSLog(@"\n\n");
//tSize =  CGSizeMake(40, 50);
//NSLog(@"100*100_%i*%i ==> size: %@", (int)tSize.width, (int)tSize
//      .height, NSStringFromCGSize([FFMpegCmd sizeFrom:CGSizeMake(100, 100) targetSize:tSize]));
//NSLog(@"80*60  _%i*%i ==> size: %@", (int)tSize.width, (int)tSize
//      .height, NSStringFromCGSize([FFMpegCmd sizeFrom:CGSizeMake(80, 60) targetSize:tSize]));
//NSLog(@"60*80  _%i*%i ==> size: %@", (int)tSize.width, (int)tSize
//      .height, NSStringFromCGSize([FFMpegCmd sizeFrom:CGSizeMake(60, 80) targetSize:tSize]));
//
//
//NSLog(@"\n\n");
//tSize =  CGSizeMake(50, 50);
//NSLog(@"100*100_%i*%i ==> size: %@", (int)tSize.width, (int)tSize
//      .height, NSStringFromCGSize([FFMpegCmd sizeFrom:CGSizeMake(100, 100) targetSize:tSize]));
//NSLog(@"80*60  _%i*%i ==> size: %@", (int)tSize.width, (int)tSize
//      .height, NSStringFromCGSize([FFMpegCmd sizeFrom:CGSizeMake(80, 60) targetSize:tSize]));
//NSLog(@"60*80  _%i*%i ==> size: %@", (int)tSize.width, (int)tSize
//      .height, NSStringFromCGSize([FFMpegCmd sizeFrom:CGSizeMake(60, 80) targetSize:tSize]));
+ (CGSize)sizeFrom:(CGSize)originSize targetSize:(CGSize)targetSize {
    if (originSize.width !=0 && originSize.height != 0 && targetSize.width !=0 && targetSize.height != 0) {
        CGFloat wScale;
        CGFloat hScale;
        CGFloat tScale;
        if (originSize.width == originSize.height || targetSize.width == targetSize.height) {
            wScale = originSize.width/targetSize.width;
            hScale = originSize.height/targetSize.height;
            tScale = MIN(wScale, hScale);
            //NSLog(@"正方形");
        }else{
            if((originSize.width > originSize.height && targetSize.width > targetSize.height)
               ||(originSize.width < originSize.height && targetSize.width < targetSize.height)){
                wScale = originSize.width/targetSize.width;
                hScale = originSize.height/targetSize.height;
                tScale = MAX(wScale, hScale);
                //NSLog(@"同方向");
            }else{
                wScale = originSize.height/targetSize.width;
                hScale = originSize.width/targetSize.height;
                tScale = MAX(wScale, hScale);
                //NSLog(@"反方向");
            }
        }
        return CGSizeMake((int)(originSize.width/tScale), (int)(originSize.height/tScale));
    }else{
        return originSize;
    }
}

+ (CGSize)videoSizeFromUrl:(NSString *)url {
    if (!url) {
        return CGSizeZero;
    }
    if ([url hasPrefix:@"file://"]) {
        url = [url substringFromIndex:7];
    }
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:url]];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;//这里的矩阵有旋转角度，转换一下即可
        NSLog(@"=====hello  width:%f===height:%f",videoTrack.naturalSize.width,videoTrack.naturalSize.height);
        if (t.tx==0) {
            return CGSizeMake(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
        }else{
            return CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width);
        }
    }else{
        return CGSizeZero;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    if (self = [super init]) {
        // from https://github.com/fanmaoyu0871/VideoCutterDemo
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(threadWillExit:) name:NSThreadWillExitNotification object:nil];
    }
    return self;
}

- (void)compressVideoUrl:(NSString *)url size:(CGSize)tSize tPath:(NSString *)tPath finish:(FFMpegCompressFinishBlock)finishBlock {
    if (!url) {
        finishBlock(NO, @"FFMpegCmd url error");
        return;
    }
    if ([url hasPrefix:@"file://"]) {
        url = [url substringFromIndex:7];
    }
    
    CGSize oSize = [FFMpegCompress videoSizeFromUrl:url];
    CGSize rSize = [FFMpegCompress sizeFrom:oSize targetSize:tSize];
    if (rSize.width == 0 || rSize.height == 0) {
        finishBlock(NO, @"FFMpegCmd video size error");
        return;
    }
    // https://www.jianshu.com/p/7a186943cbdd
    // -acodec aac: aac音频, acodec,mp2:将失去声音
    NSInteger size = 600*1000*2; // 每分钟10兆的样子
    // -b: 每秒的流量
    // ,-vcodec,copy 视频将不进行压缩.
    NSString * cmd = [NSString stringWithFormat:@"ffmpeg,-i,%@,-acodec,aac,-b,%li,-s,%ix%i,%@", url, (long)size, (int)rSize.width, (int)rSize.height, tPath];
    
    
    //-vcodec,copy 和 -vf,scale=%i:%i, 不能同时选择.
    //cmd = [NSString stringWithFormat:@"ffmpeg,-i,%@,-acodec,aac,-vcodec,copy,-b,%li,-vf,scale=%i:%i,%@", url, (long)size, (int)rSize.width, (int)rSize.height, tPath];
    
    // -hwaccel,cuvid,加速,但是不能运行
    //cmd = [NSString stringWithFormat:@"ffmpeg,-i,%@,-acodec,aac,-hwaccel,videotoolbox,-b,%li,-s,%ix%i,%@", url, (long)size, (int)rSize.width, (int)rSize.height, tPath];
    
    [self compressCmd:cmd finish:finishBlock];
}

- (void)compressCmd:(NSString *)cmd finish:(FFMpegCompressFinishBlock)finishBlock {
    self.finishBlock = finishBlock;
    //[NSThread detachNewThreadSelector:@selector(threadCompressCmd:) toTarget:self withObject:cmd];
    NSLog(@"FFMpeg cmd : %@", cmd);
    NSThread * newThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadCompressCmd:) object:cmd];
    //newThread.qualityOfService = NSQualityOfServiceUserInteractive;
    [newThread setThreadPriority:1.0];
    [newThread setName:@"FFMpegCompressVideo"]; //  线程的名字
    [newThread start];
}

- (void)threadCompressCmd:(NSString *)cmd {
    NSArray * cmdArray = [cmd componentsSeparatedByString:@","];
    int argc = (int)cmdArray.count;
    char **arguments = calloc(argc, sizeof(char*));
    if(arguments != NULL) {
        for (int i = 0; i<argc; i++) {
            NSString * oneStr = cmdArray[i];
            arguments[i] = (char*)[oneStr UTF8String];
        }
        int result = ffmpeg_main(argc, arguments);
        NSLog(@"FFMpeg result: %i", result);
        
    }else{
        if (self.finishBlock) {
            self.finishBlock(NO, ThreadCompressName);
        }
    }
}

//ffmpeg命令行线程将要结束时调用
-(void)threadWillExit:(NSNotification *)notification {
    NSThread * newThread = notification.object;
    //NSLog(@"notification: %@", [notification description]);
    if ([newThread.name isEqualToString:ThreadCompressName]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.finishBlock) {
                self.finishBlock(YES, @"FFMpegCmd finish");
            }
        });
    }
}

// Apple compress code
//- (void)testSys:(char*)inputPath outPutVideoPath:(char*)outputPath  {
//    AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%s", inputPath]]];
//    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPreset960x540];
//    // AVAssetExportPresetHighestQuality 45s 80M, 60s 100M
//    // AVAssetExportPresetMediumQuality
//    // AVAssetExportPresetHighestQuality
//    // AVAssetExportPreset960x540        45s 30M, 60s 40M
//    // 创建导出的url
//    NSString *resultPath = [NSString stringWithFormat:@"%s", outputPath];
//    session.outputURL = [NSURL fileURLWithPath:resultPath];
//    session.outputFileType = AVFileTypeMPEG4;
//    // 导出视频
//    NSLog(@"导出视频中....");
//    [session exportAsynchronouslyWithCompletionHandler:^{
//        if(session.status==AVAssetExportSessionStatusCompleted) {
//            //NSLog(@"压缩后---%.2fk",[self getFileSize:resultPath]);
//            NSLog(@"视频导出完成");
//            //            if ([NSFileManager isFileExist:resultPath])
//            //            {
//                NSLog(@"视频导出完成 ok");
//                NSData * data = [NSData dataWithContentsOfFile:resultPath];
//                NSLog(@"video size : %02fMB", data.length/1024.0f/1024.0f);
//
//            //            }
//            //            else{
//            //                NSLog(@"视频导出完成 error");
//            //                [weakSelf.view.weakImageArray removeObject:weakEntity];
//            //            }
//        }else{
//            NSLog(@"视频导出完成 error");
//        }
//    }];
//}

@end
