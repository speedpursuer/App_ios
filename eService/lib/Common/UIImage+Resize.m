//
//  UIImage+Resize.m
//  eService
//
//  Created by 邢磊 on 2017/4/17.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (UIImage *)resizeToSize:(CGSize)size {
	UIGraphicsBeginImageContext(size);
	[self drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

- (UIImage *)resizeToWidth:(CGFloat)width {
	if (self.size.width <= width) {
		return self;
	}
	CGSize size = CGSizeMake(width, (int)(width * self.size.height / self.size.width));
	UIGraphicsBeginImageContext(size);
	[self drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}
@end
