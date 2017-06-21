//
//  ArticleHeaderTableViewCell.h
//  eService
//
//  Created by 邢磊 on 2017/6/2.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleFooterTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *tel;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UIButton *telIcon;
@property (weak, nonatomic) IBOutlet UIButton *addIcon;
@property (weak, nonatomic) IBOutlet UILabel *shopName;
@property (nonatomic, copy) void (^clickAddressHandle)();
- (void)configShopName:(NSString *)shopName tel:(NSString *)tel address:(NSString *)address;
@end
