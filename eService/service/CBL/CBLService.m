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
#import "UIImage+Resize.h"
#import "Configuration.h"

#define kDBName @"eservice"
#define kStorageType kCBLSQLiteStorage
#define cbserverURL @"http://121.40.197.226:8000/eservice"
#define didSyncedFlag @"didSynced"

@interface CBLService()
@property (strong, nonatomic, readonly) CBLDatabase *database;
@property (nonatomic) CBLReplication *push;
@property (nonatomic) CBLReplication *pull;
@property (nonatomic) BOOL isSynced;
//@property MRProgressOverlayView *progressView;
@property NSString *uuid;
@property dispatch_group_t group;
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
//		_uuid = @"b2db86caf5a74b4d8a645d61ce5ede9c";
		
		_isSynced = ((Configuration *)[Configuration load]).isSynced;
	}
	
//	[self enableLogging];
	
	//For test ONLY
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *applicationSupportDirectory = [paths firstObject];
	NSLog(@"applicationSupportDirectory: '%@'", applicationSupportDirectory);
	
	return self;
}

#pragma mark - Article

- (Article *)creatNewArticle {
	return [Article createArticleInDatabase:_database withUUID:_uuid];
}

- (void)saveArticle:(Article *)article {
	[self cachePhotosForArticle:article];
	
	NSError *error;
	if ([article save:&error]) {
		[self syncToServerForArticleAsyncly:article completion:nil];
		[self notifyArticleChanges];
	}else {
		[self showError];
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

- (void)deleteArticle:(Article *)article {
	NSError *error;
	
	[article deleteDocument:&error];
	
	if(!error) {
		[self syncToServerForArticleAsyncly:article completion:nil];
	}
}

- (void)loadAllImagesForArticle:(Article *)article completion:(void (^)(BOOL success))completion{
	
	dispatch_group_t group = dispatch_group_create();
	CacheManager *cacheMgr = [CacheManager sharedManager];
	
	for(ArticleEntry *entry in article.entryList) {
		if(entry.imageURL.length == 0) continue;
		dispatch_group_enter(group);
		[cacheMgr getImageWithKey:entry.imageURL completion:^(UIImage *image) {
			dispatch_group_leave(group);
		}];
	}
	
	dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		completion(YES);
	});
}

- (void)cachePhotosForArticle:(Article *)article {
	CacheManager *cacheMgr = [CacheManager sharedManager];
	
	//首先保存第一张为缩略图
	ArticleEntry *firstEntry = [article firstImageEntry];
	if(firstEntry && [firstEntry needCache]) {
		UIImage *thumb = [firstEntry.image resizeToWidth:300];
		article.thumbURL = [self remoteURLForThumbWithDocID:[article docID]];
		article.thumb = thumb;
		[cacheMgr saveImage:thumb forKey:article.thumbURL];
	}
	
	for(ArticleEntry *entry in article.entryList) {
		if([entry needCache]) {
			entry.imageURL = [self remoteURLForImagePath:entry.imagePath withDocID:[article docID]];
			[cacheMgr saveImage:entry.image forKey:entry.imageURL];
		}
	}
}

- (void)uploadPhotosForArticle:(Article *)article completion:(void (^)(BOOL success))completion {
	
	dispatch_group_t group = dispatch_group_create();
	CacheManager *cacheMgr = [CacheManager sharedManager];
	
	__block BOOL allUploaded = YES;
	__block BOOL thumbUploaded = YES;
	__block int numberOfPhotosUploaded = 0;
	
	//上传第一张为缩略图
	ArticleEntry *firstEntry = [article firstImageEntry];
	if(firstEntry && !firstEntry.uploaded) {
		dispatch_group_enter(group);
		UIImage *thumb = article.thumb? article.thumb: [article thumbImage];
		[cacheMgr uploadImage:article.thumbURL imageData:UIImageJPEGRepresentation(thumb, 0.8) completion:^(BOOL uploadeded){
			if(!uploadeded) {
				thumbUploaded = NO;
			}
			dispatch_group_leave(group);
		}];
	}
	
	for(ArticleEntry *entry in article.entryList) {
		
		if(entry.imageURL.length == 0 || entry.uploaded) continue;
		
		dispatch_group_enter(group);
		
		//在新建时可以直接调用，避免未cache而取空
		UIImage *image = entry.image? entry.image: [cacheMgr getImageWithKey:entry.imageURL];
		
		[cacheMgr uploadImage:entry.imageURL imageData:UIImageJPEGRepresentation(image, 0.8) completion:^(BOOL uploadeded){
			if(uploadeded) {
				entry.uploaded = YES;
				numberOfPhotosUploaded++;
			}else {
				allUploaded = NO;
			}
			dispatch_group_leave(group);
		}];
	}
	
	dispatch_group_notify(group, dispatch_get_main_queue(), ^{
		NSError *error;
		if(numberOfPhotosUploaded > 0) {			
			[article updateEntryList:&error];
		}
		if(!error && allUploaded && thumbUploaded) {
			completion(YES);
		}else {
			completion(NO);
		}
	});
}

- (void)syncToServerForArticleAsyncly:(Article *)article completion:(void (^)(BOOL success))completion{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self syncToServerForArticle:article completion:^(BOOL success) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if(completion) completion(success);
			});
		}];
	});
}

- (void)syncToServerForArticle:(Article *)article completion:(void (^)(BOOL success))completion{
	
	_group = dispatch_group_create();
	
	dispatch_group_enter(_group);
	
	[self uploadPhotosForArticle:article completion:^(BOOL sucesss) {
		if(sucesss) {
			[self syncToRemote];
		}else {
			completion(NO);
		}
	}];
	
	dispatch_group_notify(_group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		if(_push.lastError) {
			completion(NO);
		}else {
			completion(YES);
		}
	});
}

#pragma mark - Shop

- (Shop *)loadShop {
	return [Shop getShopInDatabase:_database withUUID:_uuid];
}

- (void)saveShop:(Shop *)shop withAvatar:(UIImage *)avatar {
	
	CacheManager *cacheMgr = [CacheManager sharedManager];
	shop.avatar = avatar;
	shop.avatarURL = [self remoteURLForShopAvatar];
	
	[cacheMgr saveImage:avatar forKey:shop.avatarURL];
	
	NSError *error;
	if ([shop save:&error]) {
		[self syncToServerForShopAsyncly:shop completion:nil];
	}else {
		[self showError];
	}
	
	//	[cacheMgr saveImage:avatar forKey:shop.avatarURL completion:^{
	//		dispatch_group_leave(group);
	//	}];
	
	
	//	dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
	//	});
}

- (void)uploadAvaterForShop:(Shop *)shop completion:(void (^)(BOOL success))completion {
	
	CacheManager *cacheMgr = [CacheManager sharedManager];
	
//	UIImage *avatar = [cacheMgr getImageWithKey:shop.avatarURL];
	
	[cacheMgr uploadImage:shop.avatarURL imageData:UIImageJPEGRepresentation(shop.avatar, 0.8) completion:^(BOOL uploadeded){
		if(uploadeded) {
			completion(YES);
		}else {
			completion(NO);
		}
	}];
}

- (void)syncToServerForShopAsyncly:(Shop *)shop completion:(void (^)(BOOL success))completion{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self syncToServerForShop:shop completion:^(BOOL success) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if(completion) completion(success);
			});
		}];
	});
}

- (void)syncToServerForShop:(Shop *)shop completion:(void (^)(BOOL success))completion{
	
	_group = dispatch_group_create();
	
	dispatch_group_enter(_group);
	
	[self uploadAvaterForShop:shop completion:^(BOOL sucesss) {
		if(sucesss) {
			[self syncToRemote];
		}else {
			completion(NO);
		}
	}];
	
	dispatch_group_notify(_group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		if(_push.lastError) {
			completion(NO);
		}else {
			completion(YES);
		}
	});
}

#pragma mark - Tip

- (Tips *)loadTips {
	return (Tips *)[Tips getModelInDatabase:_database withUUID:_uuid];
}

- (void)saveTips:(Tips *)tips {
	NSError *error;
	[tips save:&error];
}

- (void)deleteTips:(Tips *)tips {
	NSError *error;
	[tips deleteDocument:&error];
}

#pragma mark - Sync

- (void)syncToRemote {
	
	NSURL *syncUrl = [NSURL URLWithString:cbserverURL];
	
	_push = [_database createPushReplication:syncUrl];
	
	[_database setFilterNamed: @"syncedFlag" asBlock: FILTERBLOCK({
		return ![revision[@"_id"] isEqual:didSyncedFlag];
	})];
	
	_push.authenticator = [self CBLAuthenticator];
	_push.filter = @"syncedFlag";
	//	_push.continuous = YES;
	
	NSNotificationCenter *nctr = [NSNotificationCenter defaultCenter];
	[nctr addObserver:self selector:@selector(pushProgress:)
				 name:kCBLReplicationChangeNotification object:_push];
	
	[_push start];
}

- (void)pushProgress:(NSNotification *)notification {
	if(_push.status == kCBLReplicationStopped) {
		if(_push.changesCount > 0) {
			if(_push.completedChangesCount == _push.changesCount) {
				NSLog(@"Sync to remote completed");
				dispatch_group_leave(_group);
			}else{
				NSLog(@"Sync to remote in progress");
			}
		}else {
			NSLog(@"No need to sync to remote");
			dispatch_group_leave(_group);
		}
	}
}

- (void)syncFromRemote {
	
	if(_isSynced) return;
	
	NSURL *syncUrl = [NSURL URLWithString:cbserverURL];
	
	_pull = [_database createPullReplication:syncUrl];
	
	_pull.authenticator = [self CBLAuthenticator];
	_pull.channels = @[[NSString stringWithFormat:@"user_%@", _uuid]];
	
	NSNotificationCenter *nctr = [NSNotificationCenter defaultCenter];
	[nctr addObserver:self selector:@selector(pullProgress:)
				 name:kCBLReplicationChangeNotification object:_pull];
	
	[_pull start];
}

- (void)pullProgress:(NSNotification *)notification {
	if(_pull.status == kCBLReplicationStopped) {
		if(_pull.changesCount > 0) {
			if(_pull.completedChangesCount == _pull.changesCount) {
				NSLog(@"Sync to remote completed");
				[self setSynced];
				[self notifyArticleChanges];
//				[self notifyTipsChanges];
			}else{
				NSLog(@"Sync to remote in progress");
			}
		}else {
			[self setSynced];
			NSLog(@"No need to sync to remote");
		}
	}
}

- (void)setSynced {
	Configuration *config = [Configuration load];
	config.isSynced = YES;
	[config save];
}

- (id<CBLAuthenticator>)CBLAuthenticator {
	return [CBLAuthenticator basicAuthenticatorWithName: @"eservice_user"
											   password: @"xiaodianzhang123"];
}

#pragma mark - Generic DB Opt

- (NSDictionary *)propertiesWithDocID:(NSString *)docID {
	CBLDocument* doc = [_database documentWithID:docID];
	return doc.properties? doc.properties: @{};
}

- (BOOL)saveDocWithProperties:(NSDictionary *)properties withDocID:(NSString *)docID withType:(NSString *)type{
	CBLDocument* document = [_database documentWithID:docID];
	NSError* error;
	NSMutableDictionary *dict = [properties mutableCopy];
	[dict setValue:type forKey:@"type"];
	[dict setValue:_uuid forKey:@"owner"];
	return [document putProperties:[dict copy] error:&error];
}

- (BOOL)deleteDocWithDocID:(NSString *)docID {
	CBLDocument* doc = [_database documentWithID:docID];
	NSError* error;
	return [doc deleteDocument: &error];
}

#pragma mark - Helper 
- (void)showErrorWithMessage:(NSString *)msg {
	[JDStatusBarNotification showWithStatus:msg dismissAfter:2.0 styleName:JDStatusBarStyleWarning];
}

- (void)showError{
	[self showErrorWithMessage:NSLocalizedString(@"Request failed, please retry", @"cblservice")];
}

- (NSString *)remoteURLForImagePath:(NSString *)path withDocID:(NSString *)docID {
	return [self remoteURLFromFileName:[self MD5:path] withPath:docID];
}

- (NSString *)remoteURLForThumbWithDocID:(NSString *)docID {
	return [self remoteURLFromFileName:@"thumb" withPath:docID];
}

- (NSString *)remoteURLForShopAvatar {
	return [self remoteURLFromFileName:@"avatar" withPath:@"shop"];
}

- (NSString *)remoteURLFromFileName:(NSString *)FileName withPath:(NSString *)path {
	return [NSString stringWithFormat:@"%@/%@/%@", _uuid, path, FileName];
}

- (NSString *)MD5:(NSString *)string {
	CocoaSecurityResult *md5 = [CocoaSecurity md5:string];
	return md5.hexLower;
}

- (void)notifyArticleChanges {
	[[NSNotificationCenter defaultCenter] postNotificationName:kArticleListChange object:nil];
}

- (void)notifyTipsChanges {
	[[NSNotificationCenter defaultCenter] postNotificationName:kTipsChange object:nil];
}

- (void)enableLogging {
	//        [CBLManager enableLogging:@"Database"];
	//        [CBLManager enableLogging:@"View"];
	//        [CBLManager enableLogging:@"ViewVerbose"];
	//        [CBLManager enableLogging:@"Query"];
	[CBLManager enableLogging:@"Sync"];
	[CBLManager enableLogging:@"SyncVerbose"];
	//        [CBLManager enableLogging:@"ChangeTracker"];
}
@end
