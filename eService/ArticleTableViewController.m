//
//  TestTableViewController.m
//  eService
//
//  Created by 邢磊 on 2017/4/11.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "ArticleTableViewController.h"
//#import "LFImagePickerController.h"
#import "EditTableViewController.h"
#import "ArticleTableViewCell.h"
#import "ArticleDisplayTableViewController.h"
#import "TZImagePickerController.h"
#import "ShopSettingTableViewController.h"

@interface ArticleTableViewController ()  <TZImagePickerControllerDelegate, UISearchResultsUpdating>
@property (strong, nonatomic) UISearchController *searchController;
@property NSArray <Article*> *filteredArticles;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *setupBtn;
@end

@implementation ArticleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self configCrl];
	[self showHelpOverlay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kArticleListChange object:nil];
}

- (void)configCrl {
	[self setTitle:[Helper appName]];
	[self hideBackButtonText];
	[self configSearchbar];
	[self configSettingBtn];
	[self loadData];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loadData)
												 name:kArticleListChange
											   object:nil];
	
	[[CBLService sharedManager] syncFromRemote];
}

- (void)loadData{
	_articles = [[[CBLService sharedManager] loadArticles] mutableCopy];
	[self.tableView reloadData];
}

- (void)hideBackButtonText {
	self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)configSettingBtn {
//	[_setupBtn setEnabled:NO];
//	[_setupBtn setTintColor: [UIColor clearColor]];
//	return;
	FAKIonIcons *icon = [FAKIonIcons iosGearIconWithSize:20];
	_setupBtn.image = [icon imageWithSize:CGSizeMake(20, 20)];
	_setupBtn.title = @"";
}

- (void)showHelpOverlay {
	[[TipsService shared] showHelpType:CreateNewArticle];
}

- (void)configSearchbar {
	self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
	self.searchController.searchResultsUpdater = self;
	self.searchController.dimsBackgroundDuringPresentation = NO;
//	self.searchController.searchBar.delegate = self;
	self.tableView.tableHeaderView = self.searchController.searchBar;
	self.definesPresentationContext = YES;
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

#pragma mark - Action

- (IBAction)shopSetup:(id)sender {	ShopSettingTableViewController *ctr = [[UIStoryboard storyboardWithName:@"shop" bundle:nil] instantiateViewControllerWithIdentifier:@"setting"];
	
	[self.navigationController pushViewController:ctr animated:YES];
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
	WeakSelf
	[Helper performBlock:^{
		ArticleDisplayTableViewController *vc = [ArticleDisplayTableViewController new];
		vc.article = _articles[0];
		[weakSelf.navigationController pushViewController:vc animated:YES];
	} afterDelay:0.1];
}

#pragma mark - Search bar delegate 

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
	NSString *searchString = searchController.searchBar.text;
	[self searchForText:searchString];
	[self.tableView reloadData];
}

- (void)searchForText:(NSString *)text {
	NSPredicate *thePredicate = [NSPredicate predicateWithBlock:^BOOL(Article* article, NSDictionary *bindings) {
		
		NSMutableString *fullText = [article.title mutableCopy];
		for(ArticleEntry *entry in article.entryList) {
			if(entry.desc.length > 0) {
				[fullText appendFormat:@" %@", entry.desc];
			}
		}
		return [fullText.lowercaseString containsString:text.lowercaseString];
	}];
	_filteredArticles = [_articles filteredArrayUsingPredicate:thePredicate];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (_articles.count > 0) {
		self.tableView.backgroundView = nil;
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		self.searchController.searchBar.hidden = NO;
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
		self.searchController.searchBar.hidden = YES;
		return 0;
	}
//	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if([self isSearchBarActive]) {
		return _filteredArticles.count;
	}
    return _articles.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ArticleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"article" forIndexPath:indexPath];
	
	Article *article;
	
	if([self isSearchBarActive]) {
		article = _filteredArticles[indexPath.row];		
	}else {
		article = _articles[indexPath.row];
	}
		
	[cell setCellData:article.thumbURL
				title:article.title
//				count:[NSString stringWithFormat:@"%ld %@", article.entryList.count, NSLocalizedString(@"pics", @"pics")]
	];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	ArticleDisplayTableViewController *vc = [ArticleDisplayTableViewController new];
	if([self isSearchBarActive]) {
		vc.article = _filteredArticles[indexPath.row];
	}else {
		vc.article = _articles[indexPath.row];
	}
	[self.navigationController pushViewController:vc animated:YES];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if([self isSearchBarActive]) {
		return UITableViewCellEditingStyleNone;
	}
	return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		[[[UIAlertView alloc] initWithTitle:@"删除此内容？" message:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定" block:^(UIAlertView *alertView, NSInteger buttonIndex) {
			if (buttonIndex == 1) {
				// Delete the row from the data source
				[[CBLService sharedManager] deleteArticle:_articles[indexPath.row]];
				[_articles removeObjectAtIndex:indexPath.row];
				if (_articles.count == 0) {
					[tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];
					return;
				}
				[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
			}else {
				[self setEditing:NO animated:YES];
			}
		}] show];
	}
}

- (BOOL)isSearchBarActive {
	return self.searchController.active && self.searchController.searchBar.text.length != 0;
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
