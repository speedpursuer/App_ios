//
//  ArticleTableViewCell.h
//  eService
//
//  Created by 邢磊 on 2017/4/16.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleTableViewCell : UITableViewCell
- (void)setCellData:(NSString *)thumbURL title:(NSString *)title count:(NSString *)count;
@end
