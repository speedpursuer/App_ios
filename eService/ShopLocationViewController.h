//
//  ShopLocationViewController.h
//  eService
//
//  Created by 邢磊 on 2017/5/16.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopLocationViewController : UIViewController
@property float initLat;
@property float initLng;
@property (nonatomic, copy) void (^selectAddressHandle)(NSString *city, NSString *name, NSString *address, float lat, float lng);
@end
