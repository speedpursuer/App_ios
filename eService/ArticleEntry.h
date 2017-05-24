//
//  ArticleEntity.h
//  eService
//
//  Created by 邢磊 on 2017/4/12.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <CouchbaseLite/CouchbaseLite.h>

@interface ArticleEntry : NSObject <CBLJSONEncoding>
@property UIImage *image;
@property NSString *imageURL;
@property NSString *imagePath;
@property NSString *desc;
@property BOOL uploaded;
@property CGSize size;

- (instancetype)initWithImage:(UIImage *)image withImagePath:(NSString *)path;
- (instancetype)initForPhotoDisplayOnlyWithImageURL:(NSString *)url withSize:(CGSize)size;
- (instancetype)initEmptyEntry;
- (instancetype)initWithCopy:(ArticleEntry *)entry;
- (void)updateImageWithNewImage:(UIImage *)image;
- (BOOL)hasNoImage;
- (BOOL)needCache;
- (UIImage *)fetchImage;
//- (instancetype)initWithImageURL:(NSString *)url withSize:(CGSize)size;
//- (instancetype)initWithImage:(UIImage *)image withImageURL:(NSString *)url;
@end
