//
//  CBLService.m
//  eService
//
//  Created by 邢磊 on 2017/4/26.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "CBLService.h"
#import <CouchbaseLite/CouchbaseLite.h>
#import "JDStatusBarNotification.h"
#import "CocoaSecurity.h"
#import "FCUUID.h"

#define kDBName @"eservice"
#define kStorageType kCBLForestDBStorage

@interface CBLService()
@property (strong, nonatomic, readonly) CBLDatabase *database;
@property (nonatomic) CBLReplication *push;
@property (nonatomic) CBLReplication *pull;
@property (nonatomic) BOOL isSynced;
@property (nonatomic) NSError *lastSyncError;
//@property MRProgressOverlayView *progressView;
@property NSString *uuid;
@property BOOL isSyncing;
@end

@implementation CBLService
+ (id)sharedManager {
	static CBLService *sharedMyManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedMyManager = [[self alloc] init];
	});
	return sharedMyManager;
}

- (instancetype)init {
	if (self = [super init]) {
		NSString *dbName = kDBName;
		
		CBLDatabaseOptions *option = [[CBLDatabaseOptions alloc] init];
		option.create = YES;
		option.storageType = kStorageType;
		//	option.encryptionKey = kEncryptionEnabled ? kEncryptionKey : nil;
		
		NSError *error;
		_database = [[CBLManager sharedInstance] openDatabaseNamed:dbName
													   withOptions:option
															 error:&error];
		if (error)
			NSLog(@"Cannot create database with an error : %@", [error description]);
		
		_uuid = [FCUUID uuidForDevice];
	}
	
	//	[self enableLogging];
	
	//	CBLModelFactory* factory = _database.modelFactory;
	//	[factory registerClass:[Album class] forDocumentType:@"album"];
	//	[factory registerClass:[Favorite class] forDocumentType:@"favorite"];
	//	[factory registerClass:[AlbumSeq class] forDocumentType:@"albumSeq"];
//	[self initContentDB];
//	[self loadContent];
//	[self loadFavorite];
//	[self loadAlbumSeq];
//	[self loadSynced];
//	[self observeChanges];
//	[self syncToRemote];
	
	//For test ONLY
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *applicationSupportDirectory = [paths firstObject];
	NSLog(@"applicationSupportDirectory: '%@'", applicationSupportDirectory);
	
	return self;
}

- (Article*)creatAlubmWithTitle:(NSString *) title category:(NSString *)category entryList:(NSArray *)entryList  {
	
	[self cachePhotosWithEntryList:entryList];
	
	Article* article = [Article getAlbumInDatabase:_database title:title category:category entryList:entryList withUUID:_uuid];
	NSError *error;
	
	if ([article save:&error]) {
		[JDStatusBarNotification showWithStatus:[NSString stringWithFormat:NSLocalizedString(@"New article \"%@\" created", @"cblservice"), article.title] dismissAfter:2.0 styleName:JDStatusBarStyleSuccess];
		return article;
	}else {
		[self showError];
		return nil;
	}
}

- (void)cachePhotosWithEntryList:(NSArray *)entryList {
	CacheManager *cacheMgr = [CacheManager sharedManager];
	for(ArticleEntry *entry in entryList) {
		entry.imageURL = [self remoteFileNameFromURL:entry.imageURL];
		[cacheMgr saveImage:entry.image forKey:entry.imageURL];
	}
}

- (NSArray <Article *> *)loadArticles {
	CBLView* view = [_database viewNamed: @"articles"];
	
	view.documentType = @"article";
	[view setMapBlock: MAPBLOCK({
		emit(doc[@"_id"], nil);
	}) version: @"1"];
	
	CBLQuery* query = [view createQuery];
	query.descending = YES;
	
	NSError *error;
	NSMutableArray *allArticles = [NSMutableArray new];
	CBLQueryEnumerator* result = [query run: &error];
	for (CBLQueryRow* row in result) {
		[allArticles addObject:[Article modelForDocument:row.document]];
	}
	return [allArticles copy];
}

#pragma mark - Helper 
- (void)showErrorWithMessage:(NSString *)msg {
	[JDStatusBarNotification showWithStatus:msg dismissAfter:2.0 styleName:JDStatusBarStyleWarning];
}

- (void)showError{
	[self showErrorWithMessage:NSLocalizedString(@"Request failed, please retry", @"cblservice")];
}

- (NSString *)remoteFileNameFromURL:(NSString *)url {
	return [NSString stringWithFormat:@"%@/%@", _uuid, [self MD5:url]];
}

- (NSString *)MD5:(NSString *)string {
	CocoaSecurityResult *md5 = [CocoaSecurity md5:string];
	return md5.base64;
}

@end
