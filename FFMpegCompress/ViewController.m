//
//  ViewController.m
//  FFMpegCompress
//
//  Created by apple on 2018/3/10.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "ViewController.h"
#import "FFMpegCompress.h"

@interface ViewController ()

@property (nonatomic, weak  ) IBOutlet UILabel  * inputL;
@property (nonatomic, weak  ) IBOutlet UILabel  * outputL;
@property (nonatomic, weak  ) IBOutlet UIButton * startBT;

@property (nonatomic, strong) FFMpegCompress * ffmpegCmd;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCornerView:self.inputL];
    [self setCornerView:self.outputL];
    [self setCornerView:self.startBT];
    
    [self.startBT addTarget:self action:@selector(startCompressAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setCornerView:(UIView *)view {
    view.layer.cornerRadius = 5;
    view.clipsToBounds = YES;
    
}

- (void)startCompressAction {
    if (!self.ffmpegCmd) {
        self.ffmpegCmd = [FFMpegCompress new];
    }
    
    // local disk video url path
    NSString * videoUrlPath = [[NSBundle mainBundle] pathForResource:@"input" ofType:@"MOV"];
    // @"file://var/xxxxxx"; // @"var/xxxxxx";
    
    CGSize size = CGSizeMake(540, 960);//
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *tPath = [NSString stringWithFormat:@"%@/output.mp4", docDir]; // compress video save path
    
    if (![self isFileExist:videoUrlPath]) {
        NSLog(@"videoUrlPath error.");
        return;
    }
    
    if ([self isFileExist:tPath]) {
        [self deleteFile:tPath];
    }
    NSData * inputData = [NSData dataWithContentsOfFile:videoUrlPath];
    self.inputL.text = [NSString stringWithFormat:@" input mov size is %@", [self humanSize:inputData.length]];
    __weak typeof(self) weakSelf = self;
    [self.ffmpegCmd compressVideoUrl:videoUrlPath size:size tPath:tPath finish:^(BOOL finished, NSString *info) {
        if (finished) {
            NSLog(@"FFMpegCompress finish");
            NSData * outputData = [NSData dataWithContentsOfFile:tPath];
            weakSelf.outputL.text = [NSString stringWithFormat:@" output mp4 size is %@", [weakSelf humanSize:outputData.length]];
        }else{
            NSLog(@"FFMpegCompress error: %@", info);
            weakSelf.inputL.text = @" error";
        }
    }];
}

- (BOOL)isFileExist:(NSString *)filePath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        // 如果存在的话，直接返回就好了。
        return YES;
    }else {
        return NO;
    }
    // end.
}

- (void)deleteFile:(NSString *)filePath {
    if (!filePath) {
        return;
    }else{
        filePath = [filePath stringByRemovingPercentEncoding];
    }
    if([self isFileExist:filePath]){
        NSError *error;
        if ([[NSFileManager defaultManager] removeItemAtPath:filePath error:&error] != YES){
            NSLog(@"Unable to delete file: %@", [error localizedDescription]);
        }
        // end.
    }
}

- (NSString *)humanSize:(float)fileSizeFloat {
    if (fileSizeFloat<1048576.0f) {
        return [NSString stringWithFormat:@"%.02fKB", fileSizeFloat/1024.0f];
    }else if(fileSizeFloat<1073741824.0f) {
        return [NSString stringWithFormat:@"%.02fMB", fileSizeFloat/1048576.0f];
    }else {
        return [NSString stringWithFormat:@"%.02fGB", fileSizeFloat/1073741824.0f];
    }
}

@end
