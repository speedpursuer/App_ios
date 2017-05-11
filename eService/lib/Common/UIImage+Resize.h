//
//  UIImage+Resize.h
//  eService
//
//  Created by 邢磊 on 2017/4/17.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (Resize)
- (UIImage *)resizeToSize: (CGSize)size;
- (UIImage *)resizeToWidth: (CGFloat)width;
@end
