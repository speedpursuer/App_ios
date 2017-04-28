//
//  Article.m
//  eService
//
//  Created by 邢磊 on 2017/4/16.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "Article.h"

#define kArticleDocType @"article"

@implementation Article

@dynamic entryList, title, category;

+ (NSString*) docType {
	return kArticleDocType;
}

+ (NSString*) docID:(NSString *)uuid {
	return [NSString stringWithFormat:@"article_%@_%d", uuid, (int)[NSDate date].timeIntervalSinceReferenceDate];
}

+ (Article*) getAlbumInDatabase:(CBLDatabase*) database title:(NSString *)title category:(NSString *)category entryList: (NSArray *)entryList withUUID:(NSString *)uuid {
	Article *article = (Article *)[super getModelInDatabase:database withUUID:uuid];
	article.title = title;
	article.category = category;
	article.entryList = entryList;
	return article;
}

+ (id)createArticle:(NSArray *)entryList title:(NSString *)title category:(NSString *)category {
	Article *article = [[self alloc] init];
	article.entryList = entryList;
	article.title = title;
	article.category = category;
	return article;
}

+(Class)entryListItemClass {
	return [ArticleEntry class];
}

@end
