//
//  Shop.m
//  eService
//
//  Created by 邢磊 on 2017/5/18.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "Shop.h"
#define kShopDocType @"shop"

@implementation Shop
@synthesize avatar;
@dynamic name, avatarURL, phone, address, lat, lng;
+ (NSString*) docType {
	return kShopDocType;
}

+ (NSString*) docID:(NSString *)uuid {
	return [NSString stringWithFormat:@"shop_%@", uuid];
}

-(void)setInitialValue {
	self.name = @"";
	self.avatarURL = @"";
	self.phone = @"";
	self.address = @"";
	self.lat = 0;
	self.lng = 0;
}

+ (Shop*) getShopInDatabase:(CBLDatabase*) database withUUID:(NSString *)uuid {
	Shop *shop = (Shop *)[super getModelInDatabase:database withUUID:uuid];
	return shop;
}

- (UIImage *)avatarImage {
	return [[CacheManager sharedManager] getImageWithKey:self.avatarURL];
}

@end
