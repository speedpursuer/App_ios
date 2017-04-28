//
//  DBService.m
//  eService
//
//  Created by 邢磊 on 2017/4/16.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "DBService.h"

@interface DBService()

@end
@implementation DBService

#pragma mark - Init
+ (instancetype)sharedService {
	static DBService *sharedService = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedService = [[self alloc] init];
	});
	return sharedService;
}

- (instancetype)init {
	if (self = [super init]) {
		_articleList = [NSMutableArray new];
	}
	return self;
}


- (void)saveArticle: (Article *)article {
	[_articleList addObject:article];
}
@end
