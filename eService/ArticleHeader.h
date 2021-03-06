//
//  ArticleHeader.h
//  eService
//
//  Created by 邢磊 on 2017/4/14.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleHeader : UIView
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UISwitch *enableShopSwitch;
@end
