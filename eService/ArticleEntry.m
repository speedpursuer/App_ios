//
//  ArticleEntity.m
//  eService
//
//  Created by 邢磊 on 2017/4/12.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "ArticleEntry.h"

@implementation ArticleEntry

- (instancetype)initWithImage:(UIImage *)image withImagePath:(NSString *)path {
	return [self initWithImage:image
				  withImageURL:@""
					  withSize:image.size
					  withDesc:@""
				  withUploaded:NO
				 withImagePath:path
				withCacheImage:nil
			];
}

- (instancetype)initForPhotoDisplayOnlyWithImageURL:(NSString *)url withSize:(CGSize)size {
	return [self initWithImage:nil
				  withImageURL:url
					  withSize:size
					  withDesc:@""
				  withUploaded:NO
				 withImagePath:@""
				withCacheImage:nil
		   ];
}

- (instancetype)initEmptyEntry {
	return [self initWithImage:nil
				  withImageURL:@""
					  withSize:CGSizeZero
					  withDesc:@""
				  withUploaded:NO
				 withImagePath:@""
				withCacheImage:nil
			];
}

- (instancetype)initWithCopy:(ArticleEntry *)entry {
	return [self initWithImage:entry.image
				  withImageURL:entry.imageURL
					  withSize:entry.size
					  withDesc:entry.desc
				  withUploaded:entry.uploaded
				 withImagePath:entry.imagePath
				withCacheImage:entry.cachedImage
		   ];
}

- (instancetype)initWithImage:(UIImage *)image withImageURL:(NSString *)url withSize:(CGSize)size withDesc:(NSString *)desc withUploaded:(BOOL)uploaded withImagePath:(NSString *)imagePath withCacheImage:(CachedImage *)cachedImage{
	self = super.init;
	if (self) {
		_image = image;
		_imageURL = url;
		_size = size;
		_desc = desc;
		_uploaded = uploaded;
		_imagePath = imagePath;
		_cachedImage = cachedImage;
	}
	return self;
}

- (void)updateImageWithNewImage:(UIImage *)image {
	_image = image;
	_size = image.size;
	_imageURL = @"";
	_imagePath = [NSString stringWithFormat:@"%d", (int)[NSDate date].timeIntervalSinceReferenceDate];
//	_imageURL = [NSString stringWithFormat:@"%@/%d", _imageURL, (int)[NSDate date].timeIntervalSinceReferenceDate];
	_uploaded = NO;
}

- (BOOL)hasNoImage {
	return (!_image && _imageURL.length == 0)? YES: NO;
}

- (BOOL)needCache{
	//缓存新增的、修改的照片。不必缓存已缓存的（未修改）和占位图
	return (_image && _imagePath.length > 0 && _imageURL.length == 0);
}

- (UIImage *)fetchImage {
	return self.image? self.image: [[CacheManager sharedManager] getImageWithKey:self.imageURL];
}

- (instancetype)initWithJSON: (id)jsonObject {
	if (self = [super init]) {
		self.imageURL = [jsonObject objectForKey:@"imageURL"];
		self.desc = [jsonObject objectForKey:@"desc"];
		NSNumber *width = [jsonObject objectForKey:@"width"];
		NSNumber *height = [jsonObject objectForKey:@"height"];
		self.size = CGSizeMake([width floatValue], [height floatValue]);
		self.uploaded = [[jsonObject objectForKey:@"uploaded"] boolValue];
//		self.cachedImage = [[CachedImage alloc] initWithJSON:[jsonObject objectForKey:@"cacheImage"]];
	}
	return self;
}

- (id)encodeAsJSON {
	return @{
				@"imageURL":self.imageURL,
				@"desc":self.desc,
				@"width":[NSNumber numberWithFloat:self.size.width],
				@"height":[NSNumber numberWithFloat:self.size.height],
				@"uploaded":[NSNumber numberWithBool:self.uploaded],
//				@"cacheImage": [_cachedImage encodeAsJSON]
		   };
}

//- (instancetype)initWithImage:(UIImage *)image withImageURL:(NSString *)url withDesc:(NSString *)desc {
//	return [self initWithImage:image withImageURL:url withSize:image.size withDesc:desc];
//}

//- (instancetype)initWithImage:(UIImage *)image withImageURL:(NSString *)url withSize:(CGSize)size withDesc:(NSString *)desc {
//	return [self initWithImage:image withImageURL:url withSize:size withDesc:desc withUploaded:NO withImagePath:@""];
//}

//- (instancetype)initWithImage:(UIImage *)image withImageURL:(NSString *)url {
//	return [self initWithImage:image withImageURL:url withDesc:@""];
//}

@end
