//
//  TipsService.h
//  eService
//
//  Created by 邢磊 on 2017/6/6.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTipsChange @"tipsChanged"

typedef NS_ENUM(NSInteger, TipType) {
	CreateNewArticle,
	EditTitle,
	EditPhoto,
	EnableShop,
	ShareToWX,
	ShopPhoto,
	PhotoGallery,
	PhotoSave
};

@interface TipsService : NSObject
+ (id)shared;
- (void)showHelpType:(TipType)type;
- (void)showHelpType:(TipType)type atPoint:(CGPoint)atPoint;
@end
