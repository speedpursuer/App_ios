//
//  CachedImage.m
//  eService
//
//  Created by 邢磊 on 2017/5/24.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "CachedImage.h"

@implementation CachedImage

- (instancetype)initWithURL:(NSString *)url withUploaded:(BOOL)uploaded {
	self = super.init;
	if (self) {
		_url = url;
		_uploaded = uploaded;
	}
	return self;
}

- (instancetype)initWithJSON: (id)jsonObject {
	if (self = [super init]) {
		self.url = [jsonObject objectForKey:@"url"];
		self.uploaded = [[jsonObject objectForKey:@"uploaded"] boolValue];
	}
	return self;
}

- (id)encodeAsJSON {
	return @{
				@"url":self.url,
				@"uploaded":[NSNumber numberWithBool:self.uploaded]
			};
}
@end
