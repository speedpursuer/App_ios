//
//  ArticleEntity.h
//  eService
//
//  Created by 邢磊 on 2017/4/12.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <CouchbaseLite/CouchbaseLite.h>

@interface ArticleEntry : NSObject <CBLJSONEncoding>
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *desc;
@property CGSize size;
- (instancetype)initWithImage:(UIImage *)image withImageURL:(NSString *)url;
- (instancetype)initWithImageURL:(NSString *)url withSize:(CGSize)size;
- (instancetype)initEmptyEntry;
- (void)updateImageWithNewImage:(UIImage *)image;
@end
