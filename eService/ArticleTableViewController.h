//
//  TestTableViewController.h
//  eService
//
//  Created by 邢磊 on 2017/4/11.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

@interface ArticleTableViewController : UITableViewController
@property NSMutableArray <Article*> *articles;
//@property NSArray <Article*> *articles;
@end
