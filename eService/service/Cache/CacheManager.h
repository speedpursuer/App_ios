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
- (void)removeAllCache;
@end

@interface UIImageView (ESCache)
- (void)requestImageWithURL:(NSString *)url;
- (void)requestImageWithNoPlaceholderWithURL:(NSString *)url;
- (void)requestImageWithURL:(NSString *)url completion:(YYWebImageCompletionBlock)completion;
@end
