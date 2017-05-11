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
#import "TZImagePickerController.h"
#import <FontAwesomeKit/FAKIonIcons.h>

@interface EditTableViewController () <EditArticle, LFPhotoEdittingControllerDelegate, TZImagePickerControllerDelegate>
//@property (strong, nonatomic) IBOutlet XRDragTableView *dragTableView;
@property NSMutableArray <ArticleEntry *> *entriesToEdit;
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
	self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.navigationItem.rightBarButtonItem, self.editButtonItem, nil];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//	self.tableView.backgroundColor = [UIColor lightGrayColor];
	
	[self setupEntryData];
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
	
	if([self isEditMode]) {
		_headerView.background.image = [[_existingArticle thumbImage] applyLightDarkEffect];
		_headerView.title.text = _articleTitle = _existingArticle.title;
		_headerView.category.text = _articleCategory = _existingArticle.category;
	}else {
		_headerView.background.image = [_entriesToEdit[0].image applyLightDarkEffect];
		_headerView.title.text = [self defaultTitle];
		_articleTitle = @"";
		_headerView.category.text = _articleCategory = NSLocalizedString(@"Default Category", @"Init category");
	}
	
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

- (void)setupEntryData {
	
	if([self isEditMode]) {
//		_dataArray = [[NSMutableArray alloc] initWithArray:_existingArticle.entryList];
//		_entriesToEdit = [_existingArticle.entryList mutableCopy];
		_entriesToEdit = [[_existingArticle copyOfEntryList] mutableCopy];
	}else {
		//首次编辑状态
		_entriesToEdit = [NSMutableArray new];
		for (NSInteger i = 0; i < _images.count; i++) {
			ArticleEntry *entry = [[ArticleEntry alloc]initWithImage:_images[i] withImagePath:[[_imageInfos[i] objectForKey:@"PHImageFileURLKey"]absoluteString]];
			[_entriesToEdit addObject:entry];
		}
	}
}

#pragma mark - Edit Article Delegate for cell action

- (void)editPhoto:(UITableViewCell *)cell {
	
	ArticleEntry *selectedEntry = [self entryForCell:cell];
	
	if([selectedEntry isNewEntry]) {
		TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
		imagePickerVc.allowPickingOriginalPhoto = NO;
		imagePickerVc.allowPickingGif = NO;
		imagePickerVc.allowPickingVideo = NO;
		imagePickerVc.autoDismiss = NO;
		//	imagePickerVc.maxImagesCount = 30;
		//	imagePickerVc.photoPreviewMaxWidth = 1000;
		[self presentViewController:imagePickerVc animated:YES completion:nil];
	}else {
		LFPhotoEdittingController *photoEdittingVC = [[LFPhotoEdittingController alloc] init];
		photoEdittingVC.editImage = [selectedEntry fetchImage];
		photoEdittingVC.delegate = self;
		[self presentViewController:photoEdittingVC animated:YES completion:nil];
	}
}

- (void)editDesc:(UITableViewCell *)cell {
	DescViewController *ctr = [[UIStoryboard storyboardWithName:@"common" bundle:nil] instantiateViewControllerWithIdentifier:@"desc"];
	
	ArticleEntry *entity = [self entryForCell:cell];
	
	ctr.image = [[self entryForCell:cell] fetchImage];
//	ctr.delegate = self;
	ctr.text = entity.desc;
	ctr.descPlaceholder = NSLocalizedString(@"Please enter desc", @"text for image");
	WeakSelf
	ctr.saveDescHandle = ^(NSString *desc){
		[weakSelf saveDesc:desc];
	};
//	[self presentViewController:ctr];
//	ctr.actionType = editDesc;
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
	
//	ctr.delegate = self;
	ctr.text = _articleTitle;
	ctr.descPlaceholder = NSLocalizedString(@"Please enter title", @"text for title");
	WeakSelf
	ctr.saveDescHandle = ^(NSString *desc){
		[weakSelf saveTitle:desc];
	};
//	[self presentViewController:ctr];
//	ctr.actionType = editTitle;
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
		_articleTitle = _headerView.title.text = title;
		if(_articleTitle.length == 0) {
			_headerView.title.text = [self defaultTitle];
		}
	}
}

- (void)savePhoto:(UIImage *)editedPhoto {
	UIImage *compressedImage = [UIImage imageWithData:UIImageJPEGRepresentation(editedPhoto, 0.8)];
	[[self currentEntity] updateImageWithNewImage:compressedImage];
	[self.tableView reloadData];
}

- (void)saveArticle {
	
	if(_articleTitle.length == 0) {
		_articleTitle = [self defaultTitle];
	}
	
	if([self isEditMode]) {
		[[CBLService sharedManager] updateArticle:_existingArticle WithTitle:_articleTitle category:_articleCategory entryList:_entriesToEdit];
	}else {
		[[CBLService sharedManager] creatArticleWithTitle:_articleTitle category:_articleCategory entryList:_entriesToEdit];
	}
}

#pragma mark - Navigation

- (IBAction)goBack:(id)sender {
	NSString *identifier;
	if([self isEditMode]) {
		identifier = @"backToDisplayPage";
	}else {
		identifier = @"backToArticleList";
	}
	[self performSegueWithIdentifier:identifier sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if(sender == self.saveButton) {
		[self saveArticle];
	}else {
		if([self isEditMode]) {
			[_existingArticle revertChanges];
		}
	}
}

- (IBAction)unwindFromCategoryView:(UIStoryboardSegue *)segue {
	CategoryViewController *source = [segue sourceViewController];
	_headerView.category.text = _articleCategory = source.selectedCategory;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alert didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex > 0) {
		[_entriesToEdit removeObjectAtIndex:_indexInEditing];
		[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_indexInEditing inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
	}
}

#pragma mark - Helper

- (NSString *)defaultTitle {
	return NSLocalizedString(@"Untitled", @"Init title");
}

- (BOOL)isEditMode {
	return (_existingArticle != nil);
}

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
	return _entriesToEdit[index];
}

- (void)presentViewController:(UIViewController *)ctr {
	ctr.modalPresentationStyle = UIModalPresentationCurrentContext;
	
	UINavigationController *navigationController =
	[[UINavigationController alloc] initWithRootViewController:ctr];
	
	[self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - LFPhotoEdittingControllerDelegate

- (void)lf_PhotoEdittingController:(LFPhotoEdittingController *)photoEdittingVC didCancelPhotoEdit:(LFPhotoEdit *)photoEdit {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)lf_PhotoEdittingController:(LFPhotoEdittingController *)photoEdittingVC didFinishPhotoEdit:(LFPhotoEdit *)photoEdit {
	if(photoEdit) {
		[self savePhoto:photoEdit.editPreviewImage];
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
	if(photos.count > 0) {
		[self savePhoto:photos[0]];
	}
	[picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
	[picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _entriesToEdit.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"edit" forIndexPath:indexPath];
	
	ArticleEntry *entry = _entriesToEdit[indexPath.row];
	
//	[cell setCellData:entry.image url:entry.imageURL desc:entry.desc withDelegate:self];
//	
	[cell setCellData:[entry isNewEntry]? _blankPhoto: entry.image
				  url:entry.imageURL
				 desc:entry.desc
		 withDelegate:self
	];
	
    return cell;
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
		[_entriesToEdit removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
		[_entriesToEdit insertObject:[[ArticleEntry alloc] initEmptyEntry] atIndex:indexPath.row];
		[tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	if(fromIndexPath.row != toIndexPath.row) {
		id row = [_entriesToEdit objectAtIndex:fromIndexPath.row];
		[_entriesToEdit removeObjectAtIndex:fromIndexPath.row];
		[_entriesToEdit insertObject:row atIndex:toIndexPath.row];
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
