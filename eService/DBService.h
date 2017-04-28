//
//  DBService.h
//  eService
//
//  Created by 邢磊 on 2017/4/16.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Article.h"

@interface DBService : NSObject
@property NSMutableArray <Article*> *articleList;
+ (instancetype)sharedService;
- (void)saveArticle: (Article *)article;
@end
