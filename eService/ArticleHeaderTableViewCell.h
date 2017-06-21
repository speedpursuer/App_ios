//
//  ArticleHeaderTableViewCell.h
//  eService
//
//  Created by 邢磊 on 2017/6/2.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleHeaderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *headTitle;
@property (weak, nonatomic) IBOutlet UILabel *count;

- (void)configTitle:(NSString *)title count:(NSInteger)count;
- (void)updateCount:(NSInteger)count;
@end
