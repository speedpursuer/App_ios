//
//  Article.h
//  eService
//
//  Created by 邢磊 on 2017/4/16.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBLBaseModel.h"
#import "ArticleEntry.h"
#import "Restaurant.h"

@interface Article : CBLBaseModel
@property (copy) NSArray *entryList;
@property NSString *title;
@property NSString *category;
@property UIImage *thumb;
@property NSString *thumbURL;
@property BOOL isShopEnabled;
@property NSString *date;
@property Restaurant *rest;

+ (Article*) createArticleInDatabase:(CBLDatabase*) database withUUID:(NSString *)uuid;

- (UIImage *)thumbImage;

- (BOOL)updateEntryList: (NSError**)outError;

- (NSArray <ArticleEntry *>*)copyOfEntryList;

@end
