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

#define kDBName @"eservice"
#define kStorageType kCBLForestDBStorage
#define cbserverURL @"http://121.40.197.226:8000/eservice"
#define didSyncedFlag @"didSynced"

@interface CBLService()
@property (strong, nonatomic, readonly) CBLDatabase *database;
@property (nonatomic) CBLReplication *push;
@property (nonatomic) CBLReplication *pull;
@property (nonatomic) BOOL isSynced;
@property (nonatomic) NSError *lastSyncError;
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

#pragma mark - Public methods

- (Article*)creatArticleWithTitle:(NSString *) title category:(NSString *)category entryList:(NSArray *)entryList  {
	
	Article* article = [Article createArticleInDatabase:_database title:title category:category entryList:entryList withUUID:_uuid];
	
	[self cachePhotosForArticle:article];
	
	NSError *error;
	if ([article save:&error]) {
		[self notifyArticleChanges];
//		[JDStatusBarNotification showWithStatus:[NSString stringWithFormat:NSLocalizedString(@"New article \"%@\" created", @"cblservice"), article.title] dismissAfter:2.0 styleName:JDStatusBarStyleSuccess];
		return article;
	}else {
		[self showError];
		return nil;
	}
}

- (Article*)updateArticle:(Article*)article WithTitle:(NSString *) title category:(NSString *)category entryList:(NSArray *)entryList  {
	
	article.title = title;
	article.category = category;
	article.entryList = entryList;
	
	[self cachePhotosForArticle:article];
	
	NSError *error;
	if ([article save:&error]) {
		[self notifyArticleChanges];
//		[JDStatusBarNotification showWithStatus:[NSString stringWithFormat:NSLocalizedString(@"Article \"%@\" modified", @"cblservice"), article.title] dismissAfter:2.0 styleName:JDStatusBarStyleSuccess];
		return article;
	}else {
		[self showError];
		return nil;
	}
}

- (BOOL)cachePhotosForArticle:(Article *)article {
	CacheManager *cacheMgr = [CacheManager sharedManager];
	BOOL hasImage = NO;
	for(ArticleEntry *entry in article.entryList) {
		if([entry needCache]) {
			entry.imageURL = [self remoteFileNameFromURL:entry.imagePath];
			[cacheMgr saveImage:entry.image forKey:entry.imageURL];
			//保存缩略图
			if(!hasImage) {
				article.thumbURL = [self remoteFileNameFromURL:[NSString stringWithFormat:@"%@_thumb", entry.imagePath]];
				[cacheMgr saveImage:[entry.image resizeToWidth:300] forKey:article.thumbURL];
			}
			
			hasImage = YES;
		}
	}
	return hasImage;
}

- (void)cachePhotosWithEntryList:(NSArray *)entryList {
	CacheManager *cacheMgr = [CacheManager sharedManager];
	for(ArticleEntry *entry in entryList) {
		if([entry needCache]) {
			entry.imageURL = [self remoteFileNameFromURL:entry.imagePath];
			[cacheMgr saveImage:entry.image forKey:entry.imageURL];
		}
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
	
//	if(!error) {
//		[self notifyArticleChanges];
//	}
}

- (void)loadAllImagesForArticle:(Article *)article completion:(void (^)(BOOL success))completion{
	
	dispatch_group_t group = dispatch_group_create();
	CacheManager *cacheMgr = [CacheManager sharedManager];
	
	for(ArticleEntry *entry in article.entryList) {
		dispatch_group_enter(group);
		[cacheMgr getImageWithKey:entry.imageURL completion:^(UIImage *image) {
			dispatch_group_leave(group);
		}];
	}
	
	dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		completion(YES);
	});
}

- (void)loadAllImagesForArticle:(Article *)article {
	CacheManager *cacheMgr = [CacheManager sharedManager];
	for(ArticleEntry *entry in article.entryList) {
		[cacheMgr getImageWithKey:entry.imageURL];
	}
}

- (void)uploadPhotosForArticle:(Article *)article completion:(void (^)(BOOL success))completion {
	
	dispatch_group_t group = dispatch_group_create();
	CacheManager *cacheMgr = [CacheManager sharedManager];
	
	ArticleEntry *firstEntry = [self getFirstEntryWithArticle:article];
	BOOL needUploadThumb = firstEntry && !firstEntry.uploaded;
	
	__block BOOL allUploaded = YES;
	__block BOOL thumbUploaded = YES;
	__block int numberOfPhotosUploaded = 0;
	
	for(ArticleEntry *entry in article.entryList) {
		
		if(entry.imageURL.length == 0 || entry.uploaded) continue;
		
		dispatch_group_enter(group);
		[cacheMgr uploadImage:entry.imageURL imageData:UIImageJPEGRepresentation([cacheMgr getImageWithKey:entry.imageURL], 0.8) completion:^(BOOL uploadeded){
			if(uploadeded) {
				entry.uploaded = YES;
				numberOfPhotosUploaded++;
			}else {
				allUploaded = NO;
			}
			dispatch_group_leave(group);
		}];
	}
	
	if(needUploadThumb) {
		dispatch_group_enter(group);
		[cacheMgr uploadImage:article.thumbURL imageData:UIImageJPEGRepresentation([article thumbImage], 0.8) completion:^(BOOL uploadeded){
			if(!uploadeded) {
				thumbUploaded = NO;
			}
			dispatch_group_leave(group);
		}];
	}
	
	dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
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

- (ArticleEntry *)getFirstEntryWithArticle:(Article *)article {
	for(ArticleEntry *entry in article.entryList) {
		if(entry.imageURL.length > 0) {
			return entry;
		}
	}
	return nil;
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

- (void)syncToRemote {
	
	NSURL *syncUrl = [NSURL URLWithString:cbserverURL];
	
	_push = [_database createPushReplication:syncUrl];
	
	[_database setFilterNamed: @"syncedFlag" asBlock: FILTERBLOCK({
		return ![revision[@"_id"] isEqual:didSyncedFlag];
	})];
	
	id<CBLAuthenticator> auth;
	auth = [CBLAuthenticator basicAuthenticatorWithName: @"eservice_user"
											   password: @"xiaodianzhang123"];
	_push.authenticator = auth;
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
	return md5.hexLower;
}

- (void)notifyArticleChanges {
	[[NSNotificationCenter defaultCenter] postNotificationName:kArticleListChange object:nil];
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
