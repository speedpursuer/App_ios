//
//  ArticleEntity.m
//  eService
//
//  Created by 邢磊 on 2017/4/12.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "ArticleEntity.h"

@implementation ArticleEntity
- (instancetype)initWithImage:(UIImage *)image {
	self = super.init;
	if (self) {
		_image = image;
		_desc = @"";
	}
	return self;
}
@end
