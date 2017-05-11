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
//#import "UITableView+FDTemplateLayoutCell.h"

#define photoWidth ([[UIScreen mainScreen] bounds].size.width - 2 * 8)

@interface ArticleDisplayTableViewController () <TZImagePickerControllerDelegate, PECropViewControllerDelegate>
@property NSArray *dataArray;
@end

@implementation ArticleDisplayTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self hideBackButtonText];
	[self processData];
	[self configTableView];
	[self configHeader];
	[self configCtr];
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

- (void)processData {
	NSMutableArray *array = [NSMutableArray new];
	for(ArticleEntry *entry in _article.entryList) {
		if([self hasDescInEntry:entry]) {
			[array addObject:entry.desc];
		}
		
		if([self hasPhotoInEntry:entry]) {
			ArticleEntry *newEntry = [[ArticleEntry alloc] initForPhotoDisplayOnlyWithImageURL:entry.imageURL withSize:entry.size];
			[array addObject:newEntry];
		}		
	}
	_dataArray = [array copy];
	
	self.title = _article.title;
}

-(void)configTableView {
	[self.tableView registerNib: [UINib nibWithNibName:@"ArticleTextTableViewCell" bundle:nil] forCellReuseIdentifier:@"text"];
	
	[self.tableView registerNib: [UINib nibWithNibName:@"ArticlePhotoTableViewCell" bundle:nil] forCellReuseIdentifier:@"photo"];

	
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	self.tableView.estimatedRowHeight = 400;
}

-(void)configHeader {
	ArticleEntry *firstEntry = _article.entryList.firstObject;
	if(![self hasDescInEntry:firstEntry]) {
		UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 8)];
		[self.tableView setTableHeaderView:headerView];
	}
}

- (void)configCtr {
//	UIButton *button1 = [UIButton buttonWithType:UIButtonTypeSystem];
//	[button1 setTitle:@"分享" forState:UIControlStateNormal];
//	[button1 sizeToFit];
//	[button1 addTarget:self action:@selector(selectWX:) forControlEvents:UIControlEventTouchUpInside];
//	UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithCustomView:button1];
//	
//	UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
//	[button2 setTitle:@"修改" forState:UIControlStateNormal];
//	[button2 sizeToFit];
//	[button2 addTarget:self action:@selector(editArticle:) forControlEvents:UIControlEventTouchUpInside];
//	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithCustomView:button2];
//	
//	self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:shareButton, editButton, nil];
	
	self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(selectWX:)], [[UIBarButtonItem alloc] initWithTitle:@"修改" style:UIBarButtonItemStylePlain target:self action:@selector(editArticle:)], nil];
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
//	[popoverView showToView:sender withActions:[self WXActions]];
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
	
	PopoverAction *nineAction = [PopoverAction actionWithImage:[UIImage imageNamed:@"weixin"] title:@"朋友圈九宫图" handler:^(PopoverAction *action) {
		[self selectPhotoToCrop];
	}];
	
	return @[sessionAction, timelineAction, sessionLongAction, timelineLongAction, nineAction];
}

-(void)shareToWXWithOption:(enum WXScene)scene {
	[ProgressHUD showInThread];
	[[CBLService sharedManager] syncToServerForArticle:_article completion:^(BOOL success) {
		[ProgressHUD hideInThread];
		if(success){
			UIImage *thumbImage = [[_article thumbImage] resizeToWidth:100];
			if(![WXApiRequestHandler sendLinkURL:[NSString stringWithFormat:@"%@/%@", @"http://www.carlub.cn/share", _article.docID]
									 TagName:_article.title
									   Title:_article.title
								 Description:@"由「小店长APP」制作"
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
	[[CBLService sharedManager] loadAllImagesForArticle:_article];
	[TYSnapshot screenSnapshot:self.tableView finishBlock:^(UIImage *snapShotImage) {
		[ProgressHUD hide];
		if(snapShotImage){
			if(![WXApiRequestHandler sendImageData:UIImageJPEGRepresentation(snapShotImage, 0.8)
									   TagName:_article.title
									MessageExt:_article.title
										Action:@"由「小店长App」制作"
									ThumbImage:[[_article thumbImage] resizeToWidth:500]
									   InScene:scene]) {
				[Helper showAlertMessage:@"未安装微信" withMessage:@"请下载安装"];
			}
		}else{
			[Helper showAlertMessage:@"操作未成功" withMessage:@"请检查网络后重试"];
		}
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
	[self.navigationController popViewControllerAnimated:NO];
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
	controller.imageCropRect = CGRectMake((width - length) / 2,
										  (height - length) / 2,
										  length,
										  length);
	
	[self.navigationController pushViewController:controller animated:YES];	
}


#pragma mark - Navigation

- (IBAction)unwindFromEditExistingView:(UIStoryboardSegue *)segue {
	[self processData];
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
		ArticleEntry *entry = (ArticleEntry *)rowData;
		cell = [tableView dequeueReusableCellWithIdentifier:@"photo" forIndexPath:indexPath];
		[cell setCellData:entry.imageURL desc:nil];
	}else {
		cell = [tableView dequeueReusableCellWithIdentifier:@"text" forIndexPath:indexPath];
		[cell setCellData:nil desc:rowData];
	}
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	id rowData = _dataArray[indexPath.row];
	
	if([self isPhotoCellWithRowData:rowData]) {
//		UIImage *image = _dataArray[indexPath.row];
//		CGFloat height = image.size.height * (photoWidth / image.size.width);
//		return height + 8;
		
//		return UITableViewAutomaticDimension;
		
		ArticleEntry *entry = (ArticleEntry *)rowData;
		return entry.size.height * (photoWidth / entry.size.width) + 8;
	}else {
		return UITableViewAutomaticDimension;
	}
}

-(BOOL)isPhotoCellWithRowData:(id)rowData{
	return [rowData isKindOfClass:[ArticleEntry class]]? YES: NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	
//	id rowData = _dataArray[indexPath.row];
//	
//	if([rowData isKindOfClass:[NSString class]]) {
////		NSString *cellText = rowData;
//////		UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
////		
////		UIFont *cellFont = [UIFont systemFontOfSize:17.0];
////		
////		CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
////		CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
////		
////		return labelSize.height;
//////		return 400;
//		
//		return [tableView fd_heightForCellWithIdentifier:@"text" cacheByIndexPath:indexPath configuration:^(UITableViewCell <ArticleTableViewCell> *cell) {
////			cell = [tableView dequeueReusableCellWithIdentifier:@"text" forIndexPath:indexPath];
//			[cell setCellData:nil desc:rowData];
//		}];
//	}
//	
//	if([rowData isKindOfClass:[UIImage class]]) {
//		UIImage *image = _dataArray[indexPath.row];
//		CGFloat height = image.size.height * (photoWidth / image.size.width);
//		return height + 8;
//	}
//	
//	return 0;
//}


//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	UITableViewCell <ArticleTableViewCell> *cell;
//	id rowData = _dataArray[indexPath.row];
//	
//	if([rowData isKindOfClass:[NSString class]]) {
//		cell = [tableView dequeueReusableCellWithIdentifier:@"text" forIndexPath:indexPath];
////		[cell setCellData:nil desc:rowData];
//	}
//	
//	if([rowData isKindOfClass:[UIImage class]]) {
//		cell = [tableView dequeueReusableCellWithIdentifier:@"photo" forIndexPath:indexPath];
//		
//		//		UIImage *image = rowData;
//		//
//		//		if(image.size.width > 304) {
//		//			image = [image resizeToSize:(CGSizeMake(304, image.size.height * (304 / image.size.width)))];
//		//		}
//		
////		[cell setCellData:rowData desc:nil];
//	}
//	return [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1;
//}

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
