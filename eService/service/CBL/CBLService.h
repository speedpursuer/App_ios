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
- (Article *)creatNewArticle;
- (void)saveArticle:(Article *)article;
- (NSArray <Article *> *)loadArticles;
- (Shop *)loadShop;
- (void)saveShop:(Shop *)shop withAvatar:(UIImage *)avatar;
- (void)deleteArticle:(Article *)article;
- (void)syncToServerForArticle:(Article *)article completion:(void (^)(BOOL success))completion;
- (void)loadAllImagesForArticle:(Article *)article completion:(void (^)(BOOL success))completion;
- (void)syncFromRemote;
- (Tips *)loadTips;
- (void)saveTips:(Tips *)tips;
- (void)deleteTips:(Tips *)tips;
@end
