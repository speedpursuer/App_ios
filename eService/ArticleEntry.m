//
//  ArticleEntity.m
//  eService
//
//  Created by 邢磊 on 2017/4/12.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "ArticleEntry.h"

@implementation ArticleEntry
- (instancetype)initWithImage:(UIImage *)image withImageURL:(NSString *)url {
	return [self initWithImage:image withImageURL:url withDesc:@""];
}

- (instancetype)initWithImageURL:(NSString *)url withSize:(CGSize)size {
	return [self initWithImage:nil withImageURL:url withSize:size withDesc:@""];
}

- (instancetype)initEmptyEntry {
	return [self initWithImage:nil withImageURL:@"" withDesc:@""];
}

- (instancetype)initWithImage:(UIImage *)image withImageURL:(NSString *)url withDesc:(NSString *)desc {
	return [self initWithImage:image withImageURL:url withSize:image.size withDesc:desc];
}

- (instancetype)initWithImage:(UIImage *)image withImageURL:(NSString *)url withSize:(CGSize)size withDesc:(NSString *)desc {
	self = super.init;
	if (self) {
		_image = image;
		_imageURL = url;
		_size = size;
		_desc = desc;
	}
	return self;
}

- (void)updateImageWithNewImage:(UIImage *)image {
	_image = image;
	_size = image.size;
	_imageURL = [NSString stringWithFormat:@"%@_%d", _imageURL, (int)[NSDate date].timeIntervalSinceReferenceDate];
}

- (instancetype)initWithJSON: (id)jsonObject {
	if (self = [super init]) {
		self.imageURL = [jsonObject objectForKey:@"imageURL"];
		self.desc = [jsonObject objectForKey:@"desc"];
		NSNumber *width = [jsonObject objectForKey:@"width"];
		NSNumber *height = [jsonObject objectForKey:@"height"];
		self.size = CGSizeMake([width floatValue], [height floatValue]);
	}
	return self;
}

- (id)encodeAsJSON {
	return @{
				@"imageURL":self.imageURL,
				@"desc":self.desc,
				@"width":[NSNumber numberWithFloat:self.size.width],
				@"height":[NSNumber numberWithFloat:self.size.height],
		   };
}

@end
