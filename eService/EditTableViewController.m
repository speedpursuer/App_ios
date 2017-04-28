//
//  EditTableViewController.m
//  eService
//
//  Created by 邢磊 on 2017/4/11.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "EditTableViewController.h"
#import "EditTableViewCell.h"
#import "LFPhotoEdittingController.h"
#import "LFImagePickerController.h"
#import "DescViewController.h"
#import "ArticleEntry.h"
#import "ArticleHeader.h"
#import "UIImage+ImageEffects.h"
#import "CategoryViewController.h"
#import "DBService.h"
#import <FontAwesomeKit/FAKIonIcons.h>

@interface EditTableViewController () <EditArticle, LFPhotoEdittingControllerDelegate, DescDelegate>
//@property (strong, nonatomic) IBOutlet XRDragTableView *dragTableView;
@property (nonatomic, strong) NSMutableArray <ArticleEntry *> *dataArray;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property NSInteger indexInEditing;
@property NSString *articleTitle;
@property NSString *articleCategory;
@property ArticleHeader *headerView;
@property UIImage *blankPhoto;
@end

@implementation EditTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self configCrl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configCrl {
//	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.navigationItem.rightBarButtonItem, self.editButtonItem, nil];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//	self.tableView.backgroundColor = [UIColor lightGrayColor];
	
	[self setupDataArray];
	[self configHeader];
	[self setupThumbs];
	
//	self.dragTableView.dataArray = self.dataArray;
//	self.dragTableView.scrollSpeed = 10;
	
//	self.tableView = 
	
//	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
//	[self.tableView addGestureRecognizer:longPress];
}

- (void)configHeader {
	_headerView = [[[NSBundle mainBundle] loadNibNamed:@"ArticleHeader" owner:nil options:nil] lastObject];
//	_headerView.background.image = [_images[0] applyLightDarkEffect];
	_headerView.background.image = [_dataArray[0].image applyLightDarkEffect];
	_headerView.title.text = _articleTitle = NSLocalizedString(@"Untitled", @"Init title");
	_headerView.category.text = _articleCategory = NSLocalizedString(@"Default Category", @"Init category");
//	[view setPickerData:@[@"Wash", @"Care", @"Others"]];
	[self.tableView setTableHeaderView:_headerView];
	
	_headerView.title.userInteractionEnabled = YES;
	
	UITapGestureRecognizer *Tap1 = [[UITapGestureRecognizer alloc]
										 initWithTarget:self
										 action:@selector(changeTitle)];
	
	Tap1.numberOfTapsRequired = 1;
	
	[_headerView.title addGestureRecognizer:Tap1];
	
	_headerView.category.userInteractionEnabled = YES;
	
	UITapGestureRecognizer *Tap2 = [[UITapGestureRecognizer alloc]
									initWithTarget:self
									action:@selector(changeCategory)];
	
	Tap2.numberOfTapsRequired = 1;
	
	[_headerView.category addGestureRecognizer:Tap2];
	
}

- (void)setupThumbs {
	CGSize imageSize = CGSizeMake(126, 126);
	FAKIonIcons *icon = [FAKIonIcons documentIconWithSize:40];
	[icon addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor]];
	_blankPhoto = [icon imageWithSize:imageSize];
}

- (void)setupDataArray {
	
	if(_articleEntries) {
		_dataArray = [[NSMutableArray alloc] initWithArray:_articleEntries];
	}else {
		//首次编辑状态
		_dataArray = [NSMutableArray new];
		for (NSInteger i = 0; i < _images.count; i++) {
			ArticleEntry *entry = [[ArticleEntry alloc]initWithImage:_images[i] withImageURL:[[_imageInfos[i] objectForKey:@"PHImageFileURLKey"]absoluteString]];
			[_dataArray addObject:entry];
		}
	}
	
//	for (UIImage *image in _images) {
//		[_dataArray addObject:[[ArticleEntry alloc] initWithImage:image]];
//	}
}

//- (NSString *)remoteURLFromLocalURL:(NSString *)localURL withUUID:(NSString *)uuid{
//	return [NSString stringWithFormat:@"%@", kOSSURL] uuid
//}

- (IBAction)goBack:(id)sender {
	[self.view endEditing:YES];
	if(sender == self.saveButton) {		
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Edit Article Delegate for cell action

- (void)editPhoto:(UITableViewCell *)cell {
	LFPhotoEdittingController *photoEdittingVC = [[LFPhotoEdittingController alloc] init];
	
	photoEdittingVC.editImage = [self entryForCell:cell].image;
	photoEdittingVC.delegate = self;
//	photoEdittingVC.isHiddenStatusBar = NO;
//	photoEdittingVC.isHiddenNavBar = NO;
	[self presentViewController:photoEdittingVC animated:YES completion:nil];
}

- (void)editDesc:(UITableViewCell *)cell {
	DescViewController *ctr = [[UIStoryboard storyboardWithName:@"common" bundle:nil] instantiateViewControllerWithIdentifier:@"desc"];
	
	ArticleEntry *entity = [self entryForCell:cell];
	
	[ctr setImage:entity.image];
	ctr.delegate = self;
	ctr.text = entity.desc;
	ctr.descPlaceholder = NSLocalizedString(@"Please enter desc", @"text for image");
	ctr.actionType = editDesc;
	[self.navigationController pushViewController:ctr animated:YES];
}

- (void)deletePhoto:(UITableViewCell *)cell {
	[self entryForCell:cell];
	[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Are you sure to delete", @"for photo deletion")
								message:nil
							   delegate:self
					  cancelButtonTitle:NSLocalizedString(@"Cancel", @"photo deletion")
					  otherButtonTitles:NSLocalizedString(@"OK", @"photo deletion"), nil] show];
}

- (void)changeTitle {
	DescViewController *ctr = [[UIStoryboard storyboardWithName:@"common" bundle:nil] instantiateViewControllerWithIdentifier:@"desc"];
	
	ctr.delegate = self;
	ctr.text = _articleTitle;
	ctr.descPlaceholder = NSLocalizedString(@"Please enter title", @"text for title");
	ctr.actionType = editTitle;
	[self.navigationController pushViewController:ctr animated:YES];
}

- (void)changeCategory {
	CategoryViewController *ctr = [[UIStoryboard storyboardWithName:@"Article" bundle:nil] instantiateViewControllerWithIdentifier:@"category"];
	
	ctr.dataArray = @[@"Wash", @"Care", @"Others", @"Wash1", @"Care1", @"Others1", @"Wash2", @"Care2", @"Others2"];
	[self.navigationController pushViewController:ctr animated:YES];
}

#pragma mark - Desc Delegate

- (void)saveDesc:(NSString *)desc {
	if(![[self currentEntity].desc isEqualToString:desc]) {
		[self currentEntity].desc = desc;
		[self.tableView reloadData];
	}
}

-(void)saveTitle:(NSString *)title {
	if(![_articleTitle isEqualToString:title]) {
		_headerView.title.text = _articleTitle = title;
	}
}

- (void)saveArticle {
//	Article *article = [Article createArticle:_dataArray title:_articleTitle category:_articleCategory];
//	[[DBService sharedService] saveArticle:article];
	
	[[CBLService sharedManager] creatAlubmWithTitle:_articleTitle category:_articleCategory entryList:_dataArray];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if(sender == self.saveButton) {
		[self saveArticle];
	}
}

- (IBAction)unwindFromCategoryView:(UIStoryboardSegue *)segue {
	CategoryViewController *source = [segue sourceViewController];
	_headerView.category.text = _articleCategory = source.selectedCategory;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alert didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex > 0) {
		[_dataArray removeObjectAtIndex:_indexInEditing];
		[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_indexInEditing inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
	}
}

#pragma mark - Helper

- (ArticleEntry *)entryForCell:(UITableViewCell *)cell {
	return [self entityForIndex:[self indexForCell:cell]];
}

- (ArticleEntry *)currentEntity {
	return [self entityForIndex:_indexInEditing];
}

- (NSInteger)indexForCell:(UITableViewCell *)cell {
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	_indexInEditing = indexPath.row;
	return _indexInEditing;
}

- (ArticleEntry *)entityForIndex:(NSInteger)index {
	return _dataArray[index];
}

#pragma mark - LFPhotoEdittingControllerDelegate

- (void)lf_PhotoEdittingController:(LFPhotoEdittingController *)photoEdittingVC didCancelPhotoEdit:(LFPhotoEdit *)photoEdit {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)lf_PhotoEdittingController:(LFPhotoEdittingController *)photoEdittingVC didFinishPhotoEdit:(LFPhotoEdit *)photoEdit {
	if(photoEdit) {
		[[self currentEntity] updateImageWithNewImage:photoEdit.editPreviewImage];
		[self.tableView reloadData];
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"edit" forIndexPath:indexPath];
	
	ArticleEntry *entry = _dataArray[indexPath.row];
	
//	[cell setCellData:entry.image url:entry.imageURL desc:entry.desc withDelegate:self];
//	
	[cell setCellData:[self isNewEntry:entry]? _blankPhoto: entry.image
				  url:entry.imageURL
				 desc:entry.desc
		 withDelegate:self
	];
	
    return cell;
}

- (BOOL)isNewEntry:(ArticleEntry *)entry {
	return entry.imageURL.length == 0? YES: NO;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleInsert;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		[_dataArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
		[_dataArray insertObject:[[ArticleEntry alloc] initEmptyEntry] atIndex:indexPath.row];
		[tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	if(fromIndexPath.row != toIndexPath.row) {
		id row = [_dataArray objectAtIndex:fromIndexPath.row];
		[_dataArray removeObjectAtIndex:fromIndexPath.row];
		[_dataArray insertObject:row atIndex:toIndexPath.row];
	}
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


//- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
//	return proposedDestinationIndexPath;
//}

@end
