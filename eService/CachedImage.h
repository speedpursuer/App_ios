//
//  CachedImage.h
//  eService
//
//  Created by 邢磊 on 2017/5/24.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>

@interface CachedImage : NSObject <CBLJSONEncoding>
@property UIImage *image;
@property NSString *url;
@property BOOL uploaded;
- (instancetype)initWithURL:(NSString *)url withUploaded:(BOOL)uploaded;
@end
