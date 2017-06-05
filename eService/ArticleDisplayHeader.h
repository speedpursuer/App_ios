//
//  ArticleDisplayHeader.h
//  eService
//
//  Created by 邢磊 on 2017/5/30.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleDisplayHeader : UIView
@property (weak, nonatomic) IBOutlet UILabel *rest;
@property (weak, nonatomic) IBOutlet UIButton *locBtn;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *title;
- (void)configHeader:(NSString *)title date:(NSString *)date restName:(NSString *)name;
@end
