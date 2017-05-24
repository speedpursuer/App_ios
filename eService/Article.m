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

@dynamic entryList, title, category, thumbURL, isShopEnabled;
@synthesize thumb;

+ (NSString*) docType {
	return kArticleDocType;
}

+ (NSString*) docID:(NSString *)uuid {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
	[formatter setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
	return [NSString stringWithFormat:@"article_%@_%@", uuid, [formatter stringFromDate:[NSDate date]]];
}

+ (Article*) createArticleInDatabase:(CBLDatabase*) database withUUID:(NSString *)uuid {
	Article *article = (Article *)[super getModelInDatabase:database withUUID:uuid];
//	article.title = title;
//	article.category = category;
//	article.entryList = entryList;
//	article.thumbURL = [self thumbURLWithEntryList:entryList];
	return article;
}

- (NSArray <ArticleEntry *>*)copyOfEntryList {
	NSMutableArray *entriesToModify = [[NSMutableArray alloc] initWithCapacity:self.entryList.count];
	for(ArticleEntry *entry in self.entryList) {
		[entriesToModify addObject:[[ArticleEntry alloc] initWithCopy:entry]];
	}
	return [entriesToModify copy];
}

- (BOOL)updateEntryList:(NSError**)outError {
	self.entryList = [self copyOfEntryList];
	return [self save:outError];
}

- (UIImage *)thumbImage {
	return [[CacheManager sharedManager] getImageWithKey:self.thumbURL];
}

#pragma mark - Private

+ (NSString *)thumbURLWithEntryList:(NSArray *)entryList {
	for(ArticleEntry *entry in entryList) {
		if(entry.imageURL.length > 0) {
			return entry.imageURL;
		}
	}
	return @"";
}

//+ (id)createArticle:(NSArray *)entryList title:(NSString *)title category:(NSString *)category {
//	Article *article = [[self alloc] init];
//	article.entryList = entryList;
//	article.title = title;
//	article.category = category;
//	return article;
//}

+(Class)entryListItemClass {
	return [ArticleEntry class];
}

@end
