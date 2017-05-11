//
//  CacheManager.m
//  eService
//
//  Created by 邢磊 on 2017/4/26.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "CacheManager.h"
#import <AliyunOSSiOS/OSSService.h>

#define kHTTPPrefix      @"http://"
#define kHTTPsPrefix     @"https://"
#define kJPGPostfix      @"jpg"
#define kOSSEndPoint     @"oss-cn-shanghai.aliyuncs.com"
#define kOSSBucket       @"eserviceimg"
#define KOSSAccessKey    @"LTAIywqqkWBF5iqt"
#define KOSSSecretKey    @"7sry21aUF02f8kOpElGiMng5ceQfnZ"


@interface CacheManager()
@property YYImageCache *imageCache;
@property UIImage *defaultPlaceholder;
@property YYWebImageManager *imageManager;
@property OSSClient *clientOSS;
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
	
	[self initOSSClient];
}

- (YYImageCache *)setImageCache {
	NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
															   NSUserDomainMask, YES) firstObject];
	cachePath = [cachePath stringByAppendingPathComponent:@"com.lee.eService"];
	cachePath = [cachePath stringByAppendingPathComponent:@"photo"];
	return [[YYImageCache alloc] initWithPath:cachePath];
}

- (void)initOSSClient {
	
	id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:KOSSAccessKey secretKey:KOSSSecretKey];
	
	OSSClientConfiguration * conf = [OSSClientConfiguration new];
	conf.maxRetryCount = 2;
	conf.timeoutIntervalForRequest = 30;
	conf.timeoutIntervalForResource = 24 * 60 * 60;
	
	_clientOSS = [[OSSClient alloc] initWithEndpoint:[NSString stringWithFormat:@"%@%@", kHTTPsPrefix, kOSSEndPoint] credentialProvider:credential clientConfiguration:conf];
}

#pragma mark - Public method

- (void)saveImage:(UIImage *)image forKey:(NSString *)key {
	[_imageCache setImage:image imageData:nil forKey:[self URLWithImageURL:key] withType:YYImageCacheTypeAll];
	
//	[self uploadImage:key imageData:UIImageJPEGRepresentation(image, 0.8)];
}

- (UIImage *)getImageWithKey:(NSString *)key {
	return [_imageCache getImageForKey:[self URLWithImageURL:key]];
}

- (void)getImageWithKey:(NSString *)key completion:(void (^)(UIImage *image))completion{
	[_imageCache getImageForKey:key withType:YYImageCacheTypeAll withBlock:^(UIImage *image, YYImageCacheType type) {
		completion(image);
	}];
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

#pragma mark - Upload

// 异步上传
- (void)uploadImage:(NSString *)fileKey imageData:(NSData *)imageData completion:(void (^)(BOOL))completion{
	OSSPutObjectRequest * put = [OSSPutObjectRequest new];
	
	// required fields
	put.bucketName = kOSSBucket;
	put.objectKey = [NSString stringWithFormat:@"%@.%@", fileKey, kJPGPostfix];
	put.uploadingData = imageData;
	
	// optional fields
	put.contentType = @"image/jpg";
//	put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
//		NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
//	};
//	put.contentMd5 = @"";
//	put.contentEncoding = @"";
//	put.contentDisposition = @"";
	
	OSSTask * putTask = [_clientOSS putObject:put];
	
	[putTask continueWithBlock:^id(OSSTask *task) {
		NSLog(@"objectKey: %@", put.objectKey);
		if (!task.error) {
			NSLog(@"upload object success!");
			completion(YES);
		} else {
			NSLog(@"upload object failed, error: %@" , task.error);
			completion(NO);
		}
		return nil;
	}];
}


#pragma mark - Helper

- (NSString *)URLWithImageURL:(NSString *)url{
	return [NSString stringWithFormat:@"%@%@.%@/%@.%@", kHTTPPrefix, kOSSBucket, kOSSEndPoint, url, kJPGPostfix];
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
