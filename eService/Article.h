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
@property NSArray <ArticleEntry*> *entryList;
@property NSString *title;
@property NSString *category;

+ (Article*) getAlbumInDatabase:(CBLDatabase*) database title:(NSString *)title category:(NSString *)category entryList: (NSArray *)entryList withUUID:(NSString *)uuid;

+ (id)createArticle:(NSArray *)entryList title:(NSString *)title category:(NSString *)category;
@end
