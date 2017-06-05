//
//  Restaurant.m
//  eService
//
//  Created by 邢磊 on 2017/5/30.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "Restaurant.h"

@implementation Restaurant

- (instancetype)initWithName:(NSString *)name address:(NSString *)address lat:(float)lat lng:(float)lng {
	self = super.init;
	if (self) {
		_name = name;
		_address = address;
		_lat = lat;
		_lng = lng;
	}
	return self;
}


- (instancetype)initWithJSON: (id)jsonObject {
	if (self = [super init]) {
		self.name = [jsonObject objectForKey:@"name"];
		self.address = [jsonObject objectForKey:@"address"];
		self.lat = [[jsonObject objectForKey:@"lat"] floatValue];
		self.lng = [[jsonObject objectForKey:@"lng"] floatValue];		
	}
	return self;
}

- (id)encodeAsJSON {
	return @{
				@"name":self.name,
				@"address":self.address,
				@"lat":[NSNumber numberWithFloat:self.lat],
				@"lng":[NSNumber numberWithFloat:self.lng],
			};
}
@end
