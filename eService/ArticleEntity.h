//
//  ArticleEntity.h
//  eService
//
//  Created by 邢磊 on 2017/4/12.
//  Copyright © 2017年 邢磊. All rights reserved.
//


@interface ArticleEntity : NSObject
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *desc;
- (instancetype)initWithImage:(UIImage *)image;
@end
