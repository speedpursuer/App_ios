//
//  CacheManager.h
//  eService
//
//  Created by 邢磊 on 2017/4/26.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYWebImage/YYWebImage.h>

@interface CacheManager : NSObject
+ (id)sharedManager;
- (void)saveImage:(UIImage *)image forKey:(NSString *)key;
- (UIImage *)getImageWithKey:(NSString *)key;
- (void)getImageWithKey:(NSString *)key completion:(void (^)(UIImage *image))completion;
- (void)removeAllCache;
//- (void)uploadPhotosWithArticle:(Article *)article completion:(void (^)(BOOL success))completion;
- (void)uploadImage:(NSString *)fileKey imageData:(NSData *)imageData completion:(void (^)(BOOL))completion;
@end

@interface UIImageView (ESCache)
- (void)requestImageWithURL:(NSString *)url;
- (void)requestImageWithNoPlaceholderWithURL:(NSString *)url;
- (void)requestImageWithURL:(NSString *)url completion:(YYWebImageCompletionBlock)completion;
@end
