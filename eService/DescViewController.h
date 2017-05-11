//
//  DescViewController.h
//  eService
//
//  Created by 邢磊 on 2017/4/13.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef NS_ENUM(NSInteger, DescActionType) {
//	editDesc,
//	editTitle,
//};
//
//@protocol DescDelegate <NSObject>
//@optional
//-(void)saveDesc:(NSString *)desc;
//@end

@interface DescViewController : UIViewController
@property NSString *text;
@property UIImage *image;
@property NSString *descPlaceholder;
@property (nonatomic, copy) void (^saveDescHandle)(NSString *desc);
//@property DescActionType actionType;
//@property (weak) id<DescDelegate> delegate;
@end
