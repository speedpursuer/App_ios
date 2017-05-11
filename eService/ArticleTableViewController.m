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
#import "TZImagePickerController.h"

@interface ArticleTableViewController ()  <TZImagePickerControllerDelegate, LFImagePickerControllerDelegate>

@end

@implementation ArticleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self configCrl];
	[self hideBackButtonText];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kArticleListChange object:nil];
}

- (void)configCrl {
	[self setTitle:NSLocalizedString(@"Articles", @"Article title")];
	[self loadData];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loadData)
												 name:kArticleListChange
											   object:nil];
}

- (void)loadData{
	_articles = [[[CBLService sharedManager] loadArticles] mutableCopy];
	[self.tableView reloadData];
}

- (void)hideBackButtonText {
	self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (IBAction)createNewService:(id)sender {
	TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:30 delegate:self];
	
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
	
	EditTableViewController *ctr = [[UIStoryboard storyboardWithName:@"Article" bundle:nil] instantiateViewControllerWithIdentifier:@"edit"];
	ctr.images = photos;
	ctr.imageInfos = infos;
	
	[self.navigationController pushViewController:ctr animated:YES];
	[picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
	[picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)unwindFromEditView:(UIStoryboardSegue *)segue {
//	[self loadData];
//	WeakSelf
//	[Helper performBlock:^{
//		ArticleDisplayTableViewController *vc = [ArticleDisplayTableViewController new];
//		vc.article = _articles[0];
//		[weakSelf.navigationController pushViewController:vc animated:YES];
//	} afterDelay:0.2];
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
//	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _articles.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ArticleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"article" forIndexPath:indexPath];
	
	Article *article = _articles[indexPath.row];
	
	[cell setCellData:article.thumbURL
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

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Delete the row from the data source
		[[CBLService sharedManager] deleteArticle:_articles[indexPath.row]];
		[_articles removeObjectAtIndex:indexPath.row];
		if (_articles.count == 0) {
			[tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];
			return;
		}		
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
	}
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
