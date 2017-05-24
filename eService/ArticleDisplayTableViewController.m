//
//  ArticleDisplayTableViewController.m
//  eService
//
//  Created by 邢磊 on 2017/4/16.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "ArticleDisplayTableViewController.h"
//#import "ArticleDisplayTableViewCell.h"
#import "ArticleTextTableViewCell.h"
#import "ArticlePhotoTableViewCell.h"
#import "ArticleEntry.h"
#import "WXApiRequestHandler.h"
#import "UIImage+Resize.h"
#import "PopoverView.h"
#import "EditTableViewController.h"
#import "TYSnapshot.h"
#import "TZImagePickerController.h"
#import "PECropViewController.h"
#import "NineGridViewController.h"
#import "BrowserPhoto.h"
#import "MWPhotoBrowser.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "MBProgressHUD.h"
//#import "UITableView+FDTemplateLayoutCell.h"

#define photoWidth ([[UIScreen mainScreen] bounds].size.width - 2 * 8)

@interface ArticleDisplayTableViewController () <TZImagePickerControllerDelegate, PECropViewControllerDelegate, MWPhotoBrowserDelegate>
@property NSArray *dataArray;
@property NSArray *photos;
@property MBProgressHUD *hud;
@end

@implementation ArticleDisplayTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self hideBackButtonText];
	[self configTableView];
	[self configCtr];
	[self reloadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideBackButtonText {
	self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

-(void)configTableView {
	[self.tableView registerNib: [UINib nibWithNibName:@"ArticleTextTableViewCell" bundle:nil] forCellReuseIdentifier:@"text"];
	
	[self.tableView registerNib: [UINib nibWithNibName:@"ArticlePhotoTableViewCell" bundle:nil] forCellReuseIdentifier:@"photo"];
	
	
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	self.tableView.estimatedRowHeight = 400;
}

- (void)reloadData {
	[self processData];
	[self configHeaderFooter];
}

- (void)processData {
	NSMutableArray *array = [NSMutableArray new];
	NSMutableArray *photos = [NSMutableArray new];
	for(ArticleEntry *entry in _article.entryList) {
		if([self hasDescInEntry:entry]) {
			[array addObject:entry.desc];
		}
		
		if([self hasPhotoInEntry:entry]) {
//			ArticleEntry *newEntry = [[ArticleEntry alloc] initForPhotoDisplayOnlyWithImageURL:entry.imageURL withSize:entry.size];
			BrowserPhoto *photo = [BrowserPhoto photoWithURL:[NSURL URLWithString:entry.imageURL] size:entry.size index:photos.count];
			photo.caption = entry.desc;
			[array addObject:photo];
			[photos addObject:photo];
		}		
	}
	_dataArray = [array copy];
	_photos = [photos copy];
	
	self.title = _article.title;
}

-(void)configHeaderFooter {
	UIView *headerView = ![self hasDescInEntry:_article.entryList.firstObject]? [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 8)]: nil;
	[self.tableView setTableHeaderView:headerView];
	
	UIView *footView = ![self hasPhotoInEntry:_article.entryList.lastObject]? [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 8)]: nil;
	[self.tableView setTableFooterView:footView];
}

- (void)configCtr {
	self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Share", @"Share button") style:UIBarButtonItemStylePlain target:self action:@selector(selectWX:)], [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Modify", @"Modify button") style:UIBarButtonItemStylePlain target:self action:@selector(editArticle:)], nil];
}

-(BOOL)hasPhotoInEntry:(ArticleEntry *)entry {
	return entry.imageURL.length > 0? YES: NO;
}

-(BOOL)hasDescInEntry:(ArticleEntry *)entry {
	return entry.desc.length > 0? YES: NO;
}

#pragma mark - Action

-(void)editArticle:(id)sender {
	EditTableViewController *ctr = [[UIStoryboard storyboardWithName:@"Article" bundle:nil] instantiateViewControllerWithIdentifier:@"edit"];
	ctr.existingArticle = _article;
	[self.navigationController pushViewController:ctr animated:YES];
}

-(void)selectWX:(id)sender {
	PopoverView *popoverView = [PopoverView popoverView];
	[popoverView showToPoint:CGPointMake(UIScreenWidth - 20, 64) withActions:[self WXActions]];
	popoverView.style = PopoverViewStyleDark;
}

-(void)selectAcitonsForPhoto:(UIImage *)image {
	PopoverView *popoverView = [PopoverView popoverView];
	[popoverView showToPoint:CGPointMake(UIScreenWidth - 20, 64) withActions:[self photoActionsForImage:image]];
	popoverView.style = PopoverViewStyleDark;
}


- (NSArray<PopoverAction *> *)WXActions {
	
	PopoverAction *sessionAction = [PopoverAction actionWithImage:[UIImage imageNamed:@"session"] title:@"链接给好友" handler:^(PopoverAction *action) {
		[self shareToWXWithOption:WXSceneSession];
	}];
	
	PopoverAction *timelineAction = [PopoverAction actionWithImage:[UIImage imageNamed:@"timeline"] title:@"链接至朋友圈" handler:^(PopoverAction *action) {
		[self shareToWXWithOption:WXSceneTimeline];
	}];
	
	PopoverAction *sessionLongAction = [PopoverAction actionWithImage:[UIImage imageNamed:@"session"] title:@"长图给好友" handler:^(PopoverAction *action) {
		[ProgressHUD show];
		[Helper performBlock:^{
			[self shareLongPhotoWithOption:WXSceneSession];
		} afterDelay:0];
//		[self shareLongPhotoWithOption:WXSceneSession];
	}];
	
	PopoverAction *timelineLongAction = [PopoverAction actionWithImage:[UIImage imageNamed:@"timeline"] title:@"长图至朋友圈" handler:^(PopoverAction *action) {
		[ProgressHUD show];
		[Helper performBlock:^{
			[self shareLongPhotoWithOption:WXSceneTimeline];
		} afterDelay:0];
//		[self shareLongPhotoWithOption:WXSceneTimeline];
	}];
	
//	PopoverAction *nineAction = [PopoverAction actionWithImage:[UIImage imageNamed:@"weixin"] title:@"朋友圈九宫图" handler:^(PopoverAction *action) {
//		[self selectPhotoToCrop];
//	}];
	
	return @[sessionAction, timelineAction, sessionLongAction, timelineLongAction];
}

- (NSArray<PopoverAction *> *)photoActionsForImage:(UIImage *)image {
	
	PopoverAction *saveAction = [PopoverAction actionWithImage:[UIImage imageNamed:@"photos"] title:@"保存照片到相册" handler:^(PopoverAction *action) {
		[self saveImageToAlbum:image];
	}];
	
	PopoverAction *nineAction = [PopoverAction actionWithImage:[UIImage imageNamed:@"weixin"] title:@"生成朋友圈九宫图" handler:^(PopoverAction *action) {
		[self openEditor:image];
	}];
	
	return @[saveAction, nineAction];
}

-(void)shareToWXWithOption:(enum WXScene)scene {
	
	CBLService *manager = [CBLService sharedManager];
	Shop *shop = [manager loadShop];
	NSString *shareDesc = shop? [NSString stringWithFormat:@"分享自「%@」", shop.name]: @"由「小店长APP」制作";
	
	[ProgressHUD showInThread];
	[manager syncToServerForArticle:_article completion:^(BOOL success) {
		[ProgressHUD hideInThread];
		if(success){
			UIImage *thumbImage = [[_article thumbImage] resizeToWidth:100];
			if(![WXApiRequestHandler sendLinkURL:[NSString stringWithFormat:@"%@/%@", @"http://www.carlub.cn/share", _article.docID]
									 TagName:_article.title
									   Title:_article.title
								 Description:shareDesc
								  ThumbImage:thumbImage
									 InScene:scene]) {
				[Helper showAlertMessage:@"未安装微信" withMessage:@"请下载安装"];
			}
		}else {
			[Helper showAlertMessage:@"操作未成功" withMessage:@"请检查网络后重试"];
		}
	}];
}

- (void)shareLongPhotoWithOption:(enum WXScene)scene {
	[[CBLService sharedManager] loadAllImagesForArticle:_article completion:^(BOOL success) {
		if(!success) {
			[Helper showAlertMessage:@"操作未成功" withMessage:@"请重试"];
			return;
		}
		[Helper performBlock:^{
			[TYSnapshot screenSnapshot:self.tableView finishBlock:^(UIImage *snapShotImage) {
				[ProgressHUD hide];
				if(snapShotImage){
					if(![WXApiRequestHandler sendImageData:UIImageJPEGRepresentation(snapShotImage, 0.8)
												   TagName:_article.title
												MessageExt:_article.title
													Action:@"由「小店长APP」制作"
												ThumbImage:[[_article thumbImage] resizeToWidth:500]
												   InScene:scene]) {
						[Helper showAlertMessage:@"未安装微信" withMessage:@"请下载安装"];
					}
				}else{
					[Helper showAlertMessage:@"操作未成功" withMessage:@"请检查网络后重试"];
				}
			}];
		} afterDelay:0];
	}];
}

- (void)selectPhotoToCrop {
	TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
	imagePickerVc.allowPickingOriginalPhoto = NO;
	imagePickerVc.allowPickingGif = NO;
	imagePickerVc.allowPickingVideo = NO;
	imagePickerVc.autoDismiss = NO;
	//	imagePickerVc.maxImagesCount = 30;
	//	imagePickerVc.photoPreviewMaxWidth = 1000;
	[self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - Picker delegate

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
	if(photos.count > 0) {
		[self openEditor:photos[0]];
	}
	[picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
	[picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller
	didFinishCroppingImage:(UIImage *)croppedImage
				 transform:(CGAffineTransform)transform
				  cropRect:(CGRect)cropRect
{
	NineGridViewController *ctr = [[UIStoryboard storyboardWithName:@"Article" bundle:nil] instantiateViewControllerWithIdentifier:@"nineGrid"];
	ctr.didCropImage = croppedImage;
//	[self.navigationController popViewControllerAnimated:NO];
	[self.navigationController pushViewController:ctr animated:YES];
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)openEditor:(UIImage *)image
{
	PECropViewController *controller = [[PECropViewController alloc] init];
	controller.delegate = self;
	controller.image = image;
	controller.keepingCropAspectRatio = YES;
	controller.toolbarHidden = YES;
	
	CGFloat width = image.size.width;
	CGFloat height = image.size.height;
	CGFloat length = MIN(width, height);
	controller.imageCropRect = CGRectMake(0,
										  0,
										  length,
										  length);
	
	[self.navigationController pushViewController:controller animated:YES];	
}


#pragma mark - Navigation

- (IBAction)unwindFromEditExistingView:(UIStoryboardSegue *)segue {
	[self reloadData];
	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell <ArticleTableViewCell> *cell;
	
	id rowData = _dataArray[indexPath.row];
	
	if([self isPhotoCellWithRowData:rowData]) {
//		ArticleEntry *entry = (ArticleEntry *)rowData;
		BrowserPhoto *photo = (BrowserPhoto *)rowData;
		ArticlePhotoTableViewCell *pCell = [tableView dequeueReusableCellWithIdentifier:@"photo" forIndexPath:indexPath];
		WeakSelf
		pCell.clickImageHandle = ^(NSInteger index){
			[weakSelf showImageBrowserWithIndex:index];
		};
		[pCell setCellData:[photo.photoURL absoluteString] photoIndex:photo.index];
//		[pCell setCellData:entry.imageURL desc:nil photoIndex:indexPath.row];
		return pCell;
		
//		cell = [tableView dequeueReusableCellWithIdentifier:@"photo" forIndexPath:indexPath];
//		[cell setCellData:entry.imageURL desc:nil];
	}else {
		cell = [tableView dequeueReusableCellWithIdentifier:@"text" forIndexPath:indexPath];
		[cell setCellData:nil desc:rowData];
		return cell;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	id rowData = _dataArray[indexPath.row];
	
	if([self isPhotoCellWithRowData:rowData]) {
//		ArticleEntry *entry = (ArticleEntry *)rowData;
//		return entry.size.height * (photoWidth / entry.size.width) + 8;
		BrowserPhoto *photo = (BrowserPhoto *)rowData;
		return photo.size.height * (photoWidth / photo.size.width) + 8;
	}else {
		return UITableViewAutomaticDimension;
	}
}

-(BOOL)isPhotoCellWithRowData:(id)rowData{
	return [rowData isKindOfClass:[BrowserPhoto class]]? YES: NO;
//	return [rowData isKindOfClass:[ArticleEntry class]]? YES: NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

#pragma mark - Photo browser

-(void)showImageBrowserWithIndex:(NSInteger)index {
	MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
	browser.displayActionButton = YES;
//	browser.displayNavArrows = YES;
//	browser.displaySelectionButtons = displaySelectionButtons;
//	browser.alwaysShowControls = YES;
	browser.zoomPhotosToFill = YES;
//	browser.enableGrid = enableGrid;
//	browser.startOnGrid = startOnGrid;
	browser.enableSwipeToDismiss = YES;
//	browser.autoPlayOnAppear = autoPlayOnAppear;
	[browser setCurrentPhotoIndex:index];
	
	[self.navigationController pushViewController:browser animated:YES];
}

- (void)saveImageToAlbum:(UIImage *)image {
	
	_hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
	_hud.mode = MBProgressHUDModeIndeterminate;
	_hud.labelText = [NSString stringWithFormat:@"保存到相册..."];
	
	ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[assetsLibrary saveImage:image
						 toAlbum:[Helper appName]
			 withCompletionBlock:^(NSError *error) {
				 dispatch_async(dispatch_get_main_queue(), ^{
					 UIImage *image = [UIImage imageNamed:@"success"];
					 UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
					 _hud.customView = imageView;
					 _hud.mode = MBProgressHUDModeCustomView;
					 _hud.labelText = @"保存成功!";
					 [_hud hide:YES afterDelay:1.f];
				 });
			 }];
	});
}

#pragma mark - MWPhotoBrowserDelegate
				  
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
	return _photos.count;
}
				  
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
	if (index < _photos.count)
		return [_photos objectAtIndex:index];
	return nil;
}
				  
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
	// Do your thing!
	[self selectAcitonsForPhoto:((BrowserPhoto *)_photos[index]).underlyingImage];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
