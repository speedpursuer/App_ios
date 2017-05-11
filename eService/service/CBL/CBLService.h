//
//  CBLService.h
//  eService
//
//  Created by 邢磊 on 2017/4/26.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kArticleListChange @"articleModified"

@interface CBLService : NSObject
+ (id)sharedManager;
- (Article*)creatArticleWithTitle:(NSString *) title category:(NSString *)category entryList:(NSArray *)entryList;
- (Article*)updateArticle:(Article*)article WithTitle:(NSString *) title category:(NSString *)category entryList:(NSArray *)entryList ;
- (NSArray <Article *> *)loadArticles;
- (void)deleteArticle:(Article *)article;
- (void)syncToServerForArticle:(Article *)article completion:(void (^)(BOOL success))completion;
- (void)loadAllImagesForArticle:(Article *)article completion:(void (^)(BOOL success))completion;
- (void)loadAllImagesForArticle:(Article *)article;
@end
