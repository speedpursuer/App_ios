//
//  Tips.m
//  eService
//
//  Created by 邢磊 on 2017/6/6.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "Tips.h"

#define kTipsDocType @"tips"

@implementation Tips
@dynamic viewedTips;
+ (NSString*) docType {
	return kTipsDocType;
}

-(void)setInitialValue {
	self.viewedTips = @[];
}

+ (NSString*) docID:(NSString *)uuid {
	return [NSString stringWithFormat:@"tips_%@", uuid];
}

@end
