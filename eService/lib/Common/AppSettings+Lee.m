//
//  AppSettings+Cliplay.m
//  Cliplay
//
//  Created by 邢磊 on 2016/9/23.
//
//

#import "AppSettings+Lee.h"

@implementation AppSettings (Lee)
+ (id)load
{
	NSString *mainKey = NSStringFromClass([self class]);
	return [[self class] loadFromKeyWithDefault:mainKey];
}

+ (id)loadFromKeyWithDefault:(NSString*)mainKey
{
	NSDictionary *serializedSelf = [[NSUserDefaults standardUserDefaults] objectForKey:mainKey];
	
	if(serializedSelf == nil) {
		return [[[self class] alloc] init];
	}
	return [[[self class] alloc] initWithDictionary:serializedSelf];
}

@end
