//
//  TestTableViewController.m
//  eService
//
//  Created by 邢磊 on 2017/4/11.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "ArticleTableViewController.h"
#import "LFImagePickerController.h"
#import "EditTableViewController.h"
#import "ArticleTableViewCell.h"
#import "ArticleDisplayTableViewController.h"
#import "DBService.h"
#import "TZImagePickerController.h"

@interface ArticleTableViewController ()  <TZImagePickerControllerDelegate, LFImagePickerControllerDelegate>

@end

@implementation ArticleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self configCrl];
	[self hideBackButtonText];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configCrl {
	[self setTitle:NSLocalizedString(@"Articles", @"Article title")];
//	_articles = [NSMutableArray arrayWithObjects:@"Article1", @"Article2", @"Article3", nil];
//	_articles = [DBService sharedService].articleList;
//	[[CacheManager sharedManager] removeAllCache];
	[self loadData];
}

- (void)loadData{
	_articles = [[CBLService sharedManager] loadArticles];
}

- (void)hideBackButtonText {
	self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (IBAction)createNewService:(id)sender {
//	LFImagePickerController *imagePicker = [[LFImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
//	
//	//    imagePicker.allowTakePicture = NO;
//	imagePicker.sortAscendingByCreateDate = NO;
//	imagePicker.doneBtnTitleStr = NSLocalizedString(@"OK", @"Confirm photo selection");
//	imagePicker.allowEditting = NO;
//	imagePicker.allowPickingOriginalPhoto = NO;
////	imagePicker.isSelectOriginalPhoto = YES;
//	imagePicker.maxImagesCount = 50;
//	imagePicker.minImagesCount = 1;
//	imagePicker.allowPickingVideo = NO;
//	[self presentViewController:imagePicker animated:YES completion:nil];
	
	
	TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
	
	imagePickerVc.allowPickingOriginalPhoto = NO;
	imagePickerVc.allowPickingGif = NO;
	imagePickerVc.allowPickingVideo = NO;
	imagePickerVc.autoDismiss = NO;
	imagePickerVc.maxImagesCount = 30;
	//	imagePickerVc.photoPreviewMaxWidth = 1000;
	//	[self pushController:imagePickerVc];
	
	[self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - Picker delegate

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
	
	EditTableViewController *ctr = [[UIStoryboard storyboardWithName:@"Article" bundle:nil] instantiateViewControllerWithIdentifier:@"edit"];
	ctr.images = photos;
	ctr.imageInfos = infos;
	//	ctr.dataArray = [self articleEntryFromPhotos:photos infos:infos];
	[self.navigationController pushViewController:ctr animated:YES];
	[picker dismissViewControllerAnimated:YES completion:nil];
}

//- (NSMutableArray *)articleEntryFromPhotos:(NSArray *)photos infos:(NSArray *)infos {
//	NSMutableArray *entries = [NSMutableArray new];
//	for (NSInteger i = 0; i < photos.count; i++) {
//		ArticleEntry *entry = [[ArticleEntry alloc]initWithImage:photos[i] withImageKey:[infos[i] objectForKey:@"PHImageFileURLKey"]];
//		[entries addObject:entry];
//	}
//	return entries;
//}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
	[picker dismissViewControllerAnimated:YES completion:nil];
}

//- (void)lf_imagePickerController:(LFImagePickerController *)picker didFinishPickingThumbnailImages:(NSArray<UIImage *> *)thumbnailImages originalImages:(NSArray<UIImage *> *)originalImages {
//	
//	EditTableViewController *ctr = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"edit1"];
//	
//	ctr.images = originalImages;
//	[self.navigationController pushViewController:ctr animated:YES];
//}

- (IBAction)unwindFromEditView:(UIStoryboardSegue *)segue {
//	EditTableViewController *source = [segue sourceViewController];
//	_articles = [[DBService sharedService].articleList copy];
	[self loadData];
	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (_articles.count > 0) {
		self.tableView.backgroundView = nil;
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		return 1;
	} else {
		UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
		messageLabel.text = NSLocalizedString(@"No Content", @"Message for empty table view");
		messageLabel.textColor = [UIColor lightGrayColor];
		messageLabel.numberOfLines = 0;
		messageLabel.textAlignment = NSTextAlignmentCenter;
		messageLabel.font = [UIFont systemFontOfSize:20];
		[messageLabel sizeToFit];
		self.tableView.backgroundView = messageLabel;
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		return 0;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _articles.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ArticleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"article" forIndexPath:indexPath];
	
	Article *article = _articles[indexPath.row];
	
	[cell setCellData:article.entryList[0].imageURL
				title:article.title
				count:[NSString stringWithFormat:@"%ld %@", article.entryList.count, NSLocalizedString(@"pics", @"pics")]
	];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	ArticleDisplayTableViewController *vc = [ArticleDisplayTableViewController new];
	vc.article = _articles[indexPath.row];
	[self.navigationController pushViewController:vc animated:YES];
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
