//
//  BrowserPhoto.h
//  eService
//
//  Created by 邢磊 on 2017/5/13.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "MWPhotoProtocol.h"


@interface BrowserPhoto : NSObject <MWPhoto>
@property (nonatomic, strong) NSURL *photoURL;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic) BOOL emptyImage;
@property (nonatomic) BOOL isVideo;
@property NSInteger index;
@property CGSize size;

+ (BrowserPhoto *)photoWithImage:(UIImage *)image;
+ (BrowserPhoto *)photoWithURL:(NSURL *)url;
+ (BrowserPhoto *)photoWithURL:(NSURL *)url size:(CGSize)size index:(NSInteger)index;
+ (BrowserPhoto *)photoWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;
+ (BrowserPhoto *)videoWithURL:(NSURL *)url; // Initialise video with no poster image

- (id)init;
- (id)initWithImage:(UIImage *)image;
- (id)initWithURL:(NSURL *)url;
- (id)initWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;
- (id)initWithVideoURL:(NSURL *)url;
@end
