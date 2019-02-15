//
//  FFMpegCompress.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^FFMpegCompressFinishBlock)(BOOL finished, NSString * info); // __BlockTypedef

@interface FFMpegCompress : NSObject

@property (nonatomic, copy  ) FFMpegCompressFinishBlock finishBlock;
+ (CGSize)sizeFrom:(CGSize)originSize targetSize:(CGSize)targetSize;
+ (CGSize)videoSizeFromUrl:(NSString *)url;

- (void)compressCmd:(NSString *)cmd finish:(FFMpegCompressFinishBlock)finishBlock;

// 只支持本地URL
- (void)compressVideoUrl:(NSString *)url size:(CGSize)tSize tPath:(NSString *)tPath finish:(FFMpegCompressFinishBlock)finishBlock;

// 未经过严格测试.
- (NSUInteger)degressWithURL:(NSURL *)url;

@end

