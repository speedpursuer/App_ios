//
//  TipsService.m
//  eService
//
//  Created by 邢磊 on 2017/6/6.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "TipsService.h"
#import "TAOOverlayHelp.h"

@interface TipsService ()
@property Tips *tips;
@property NSMutableArray *tipList;
@end

@implementation TipsService
+ (id)shared {
	static TipsService *shared = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shared = [[self alloc] init];
	});
	return shared;
}

- (instancetype)init {
	if (self = [super init]) {
		[self load];
	}
	return self;
}

//- (void)setNotification {
//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(load)
//												 name:kTipsChange
//											   object:nil];
//}

- (void)load {
	_tips = [[CBLService sharedManager] loadTips];
	_tipList = [@[] mutableCopy];
//	[[CBLService sharedManager] deleteTips:_tips];
}

- (void)save {
	[[CBLService sharedManager] saveTips:_tips];
}

- (BOOL)tipViewed:(TipType)type {
	return [_tips.viewedTips containsObject:[self stringForInteger:type]]? YES: NO;
}

- (void)setTipViewed:(TipType)type {
	NSMutableArray *curTips = [_tips.viewedTips mutableCopy];
	[curTips addObject:[self stringForInteger:type]];
	_tips.viewedTips = [curTips copy];
	[[CBLService sharedManager] saveTips:_tips];
//	NSLog(@"%ld viewed", type);
}

- (NSString *)stringForInteger:(NSInteger)integer {
	 return [NSString stringWithFormat: @"%ld", (long)integer];
}

//- (void)showHelpTypes:(NSArray *)types {
//	for(NSNumber *typeObj in types) {
//		TipType type = [typeObj intValue];
//		[self showHelpType:type];
//	}
//}

- (void)showHelpType:(TipType)type{
	[self showHelpTypeInternal:type fromDismiss:NO atPoint:CGPointZero];
}

- (void)showHelpType:(TipType)type atPoint:(CGPoint)atPoint {
	[self showHelpTypeInternal:type fromDismiss:NO atPoint:atPoint];
}

- (void)showHelpTypeInternal:(TipType)type fromDismiss:(BOOL)fromDismiss atPoint:(CGPoint)atPoint{
	
	if([self tipViewed:type]) return;
	
	NSString *msg;
	CGPoint point;
	
	switch (type) {
		case CreateNewArticle:
			msg = NSLocalizedString(@"Click here to Create", @"点击这里新建");
			point = CGPointMake((UIScreenWidth - 20), 50);
			break;
		case EditTitle:
			msg = NSLocalizedString(@"Click here to change title", @"点击这里修改标题");
			point = CGPointMake(60, 100);
			break;
			
		case EditPhoto:
			msg = NSLocalizedString(@"Click image to edit", @"点击这里修图");
			point = CGPointMake(60, 280);
			break;
			
		case EnableShop:
			msg = NSLocalizedString(@"Click here to display Shop", @"点击这里显示门店信息");
			point = CGPointMake((UIScreenWidth - 40), 190);
			break;
			
		case ShareToWX:
			msg = NSLocalizedString(@"Click here to Share To WeChat", @"点击这里分享文章到微信");
			point = CGPointMake((UIScreenWidth - 30), 50);
			break;
			
		case ShopPhoto:
			msg = NSLocalizedString(@"Click here to set photo", @"点击这里设置门店Logo或微信二维码");
			point = CGPointMake((UIScreenWidth/2), 280);
			break;
			
		case PhotoGallery:
			msg = NSLocalizedString(@"Click Photo to zoom", @"点击图片放大或生产9宫图");
			point = atPoint;
			break;
			
		case PhotoSave:
			msg = NSLocalizedString(@"Click here to save photo", @"点击这里保存九宫图");
			point = CGPointMake((UIScreenWidth - 30), 50);
			break;
	}
	
	if(!fromDismiss) {
		[_tipList addObject:[NSNumber numberWithInteger:type]];
		if(_tipList.count > 1) {
			return;
		}
	}
	
	[self show:msg point:point];
}

- (void)show:(NSString *)msg point:(CGPoint)point {
	TAOOverlayHelp *help = [TAOOverlayHelp new];
	[help showWithHelpTip:msg pointAt:point didDismiss:^{
		[self didDismiss];
	}];
	
}

- (void)didDismiss {
	[self setTipViewed:[((NSNumber *)_tipList[0]) integerValue]];
	[_tipList removeObjectAtIndex:0];
	if(_tipList.count > 0){
		TipType type = [((NSNumber *)_tipList[0]) integerValue];
		[self showHelpTypeInternal:type fromDismiss:YES atPoint:CGPointZero];
	}
}

@end
