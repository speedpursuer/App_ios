//
//  CacheManager.m
//  eService
//
//  Created by 邢磊 on 2017/4/26.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "CacheManager.h"

#define kHTTPPrefix      @"http://"
#define kOSSURL          @"oss-cn-shanghai.aliyuncs.com"
#define kOSSBucket       @"eserviceimg"

@interface CacheManager()
@property YYImageCache *imageCache;
@property UIImage *defaultPlaceholder;
@property YYWebImageManager *imageManager;
@end

@implementation CacheManager
+ (id)sharedManager {
	static CacheManager *sharedMyManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedMyManager = [[self alloc] init];
	});
	return sharedMyManager;
}

- (instancetype)init {
	if (self = [super init]) {
		[self setup];
	}
	return self;
}

- (void)setup {
	_imageCache = [self setImageCache];
	NSOperationQueue *queue = [NSOperationQueue new];
	_imageManager = [[YYWebImageManager alloc] initWithCache:_imageCache queue:queue];
	
	_defaultPlaceholder = [Helper createImageWithColor:[UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1]];
}

- (YYImageCache *)setImageCache {
	NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
															   NSUserDomainMask, YES) firstObject];
	cachePath = [cachePath stringByAppendingPathComponent:@"com.lee.eService"];
	cachePath = [cachePath stringByAppendingPathComponent:@"photo"];
	return [[YYImageCache alloc] initWithPath:cachePath];
}

- (void)saveImage:(UIImage *)image forKey:(NSString *)key {
	[_imageCache setImage:image imageData:nil forKey:[self URLWithImageURL:key] withType:YYImageCacheTypeDisk];
}

- (void)requestImageWithURL:(NSString *)url forImageView:(UIImageView *)imageView{
	[imageView yy_setImageWithURL:[NSURL URLWithString:[self URLWithImageURL:url]]
					  placeholder:_defaultPlaceholder
						  options:YYWebImageOptionSetImageWithFadeAnimation
						  manager:_imageManager
						 progress:nil
						transform:nil
					   completion:nil
	];
}

- (void)requestImageWithNoPlaceholderWithURL:(NSString *)url forImageView:(UIImageView *)imageView{
	[imageView yy_setImageWithURL:[NSURL URLWithString:[self URLWithImageURL:url]]
					  placeholder:nil
						  options:YYWebImageOptionSetImageWithFadeAnimation
						  manager:_imageManager
						 progress:nil
						transform:nil
					   completion:nil
	 ];
}

- (void)requestImageWithURL:(NSString *)url forImageView:(UIImageView *)imageView completion:(YYWebImageCompletionBlock)completion{
	[imageView yy_setImageWithURL:[NSURL URLWithString:[self URLWithImageURL:url]]
					  placeholder:_defaultPlaceholder
						  options:kNilOptions
						  manager:_imageManager
						 progress:nil
						transform:nil
					   completion:completion
	 ];
}

- (void)removeAllCache {
	[_imageCache.memoryCache removeAllObjects];
	[_imageCache.diskCache removeAllObjects];
}

#pragma mark - Helper

- (NSString *)URLWithImageURL:(NSString *)url{
	return [NSString stringWithFormat:@"%@%@.%@/%@", kHTTPPrefix, kOSSBucket, kOSSURL, url];
}

@end

@implementation UIImageView (ESCache)
- (void)requestImageWithURL:(NSString *)url {
	[[CacheManager sharedManager] requestImageWithURL:url forImageView:self];
}

- (void)requestImageWithNoPlaceholderWithURL:(NSString *)url {
	[[CacheManager sharedManager] requestImageWithNoPlaceholderWithURL:url forImageView:self];
}

- (void)requestImageWithURL:(NSString *)url completion:(YYWebImageCompletionBlock)completion{
	[[CacheManager sharedManager] requestImageWithURL:url forImageView:self completion:completion];
}
@end
