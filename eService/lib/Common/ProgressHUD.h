//
//  ProgressHUD.h
//  eService
//
//  Created by 邢磊 on 2017/5/3.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressHUD: NSObject
+ (void)show;
+ (void)hide;
+ (void)showInThread;
+ (void)hideInThread;
@end
