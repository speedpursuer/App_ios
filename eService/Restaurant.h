//
//  Restaurant.h
//  eService
//
//  Created by 邢磊 on 2017/5/30.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>

@interface Restaurant : NSObject <CBLJSONEncoding>
@property NSString *name;
@property NSString *address;
@property float lat;
@property float lng;
- (instancetype)initWithName:(NSString *)name address:(NSString *)address lat:(float)lat lng:(float)lng;
@end
