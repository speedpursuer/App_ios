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

@interface Article : CBLBaseModel
@property (copy) NSArray *entryList;
@property NSString *title;
@property NSString *category;
@property NSString *thumbURL;

+ (Article*) createArticleInDatabase:(CBLDatabase*) database title:(NSString *)title category:(NSString *)category entryList: (NSArray *)entryList withUUID:(NSString *)uuid;

- (UIImage *)thumbImage;

- (BOOL)updateEntryList: (NSError**)outError;

- (NSArray <ArticleEntry *>*)copyOfEntryList;

@end
