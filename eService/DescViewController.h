//
//  DescViewController.h
//  eService
//
//  Created by 邢磊 on 2017/4/13.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DescActionType) {
	addDesc,
	editDesc,
};

@protocol DescDelegate <NSObject>
@optional
-(void)saveDesc:(NSString *)desc;
@end

@interface DescViewController : UIViewController
@property NSString *desc;
@property UIImage *image;
@property NSString *descPlaceholder;
@property DescActionType actionType;
@property (weak) id<DescDelegate> delegate;
@end
