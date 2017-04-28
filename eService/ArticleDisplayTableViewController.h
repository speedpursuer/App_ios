//
//  ArticleDisplayTableViewController.h
//  eService
//
//  Created by 邢磊 on 2017/4/16.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

@protocol ArticleTableViewCell <NSObject>

- (void)setCellData:(NSString *)url desc:(NSString *)desc;
//- (CGFloat)cellHeight;

@end

@interface ArticleDisplayTableViewController : UITableViewController
@property Article *article;
@end
