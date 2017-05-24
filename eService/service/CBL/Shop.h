//
//  Shop.h
//  eService
//
//  Created by 邢磊 on 2017/5/18.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "CBLBaseModelConflict.h"

@interface Shop : CBLBaseModelConflict
@property NSString *name;
@property UIImage *avatar;
@property NSString *avatarURL;
@property NSString *phone;
@property NSString *address;
@property float lat;
@property float lng;
+ (Shop*) getShopInDatabase:(CBLDatabase*) database withUUID:(NSString *)uuid;
- (UIImage *)avatarImage;
@end
