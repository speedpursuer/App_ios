//
//  EditTableViewController.m
//  eService
//
//  Created by 邢磊 on 2017/4/11.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "EditTableViewController.h"
#import "EditTableViewCell.h"
#import "LFImagePickerController.h"
#import "LFPhotoEdittingController.h"
#import "DescViewController.h"
#import "ArticleEntity.h"
#import "ArticleHeader.h"

@interface EditTableViewController () <EditArticle, LFPhotoEdittingControllerDelegate, DescDelegate>
//@property (strong, nonatomic) IBOutlet XRDragTableView *dragTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, strong) NSMutableArray <ArticleEntity *> *dataArray;
@property NSInteger indexInEditing;
@end

@implementation EditTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self configCrl];
	
//	self.tableView.backgroundColor = [UIColor lightGrayColor];
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
//	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.navigationItem.rightBarButtonItem, self.editButtonItem, nil];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	[self setupDataArray];
	[self configHeader];
	
	
//	self.dragTableView.dataArray = self.dataArray;
//	self.dragTableView.scrollSpeed = 10;
	
//	self.tableView = 
	
//	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
//	[self.tableView addGestureRecognizer:longPress];
}

- (void)configHeader {
	ArticleHeader *view = [[[NSBundle mainBundle] loadNibNamed:@"ArticleHeader" owner:nil options:nil] lastObject];	
	view.background.image = _images[0];
	view.title.text = NSLocalizedString(@"Untitled", @"Init title");
//	[view setPickerData:@[@"Wash", @"Care", @"Others"]];
	[self.tableView setTableHeaderView:view];
}

- (void)setupDataArray {
	
	_dataArray = [NSMutableArray new];
	
	for (UIImage *image in _images) {
		[_dataArray addObject:[[ArticleEntity alloc] initWithImage:image]];
	}
}

- (IBAction)goBack:(id)sender {
	[self.view endEditing:YES];
	if(sender == self.saveButton) {		
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Edit Article Delegate

//- (void)editPhoto:(NSInteger)index {
- (void)editPhoto:(UITableViewCell *)cell {
//	NSArray *array = @[[UIImage imageNamed:@"1.jpeg"], [UIImage imageNamed:@"1.jpeg"], [UIImage imageNamed:@"1.jpeg"], [UIImage imageNamed:@"1.jpeg"]];
	
//	LFImagePickerController *imagePicker = [[LFImagePickerController alloc] initWithSelectedPhotos:_images index:[self indexForCell:cell] complete:^(NSArray *photos) {
//		NSLog(@"%ld", photos.count);
//	}];
//	
//	[self presentViewController:imagePicker animated:YES completion:nil];
	
	LFPhotoEdittingController *photoEdittingVC = [[LFPhotoEdittingController alloc] init];
	
	photoEdittingVC.editImage = [self entityForCell:cell].image;
	photoEdittingVC.delegate = self;
//	photoEdittingVC.isHiddenStatusBar = NO;
//	photoEdittingVC.isHiddenNavBar = NO;
	[self presentViewController:photoEdittingVC animated:YES completion:nil];
//	[self.navigationController pushViewController:photoEdittingVC animated:YES];
	
//	photoEdittingVC.modalPresentationStyle = UIModalPresentationCurrentContext;	
//	UINavigationController *navigationController =
//	[[UINavigationController alloc] initWithRootViewController:photoEdittingVC];
//	
//	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)editDesc:(UITableViewCell *)cell {
	DescViewController *ctr = [[UIStoryboard storyboardWithName:@"common" bundle:nil] instantiateViewControllerWithIdentifier:@"desc"];
	
	ArticleEntity *entity = [self entityForCell:cell];
	
	[ctr setImage:entity.image];
	ctr.delegate = self;
	ctr.desc = entity.desc;
	ctr.descPlaceholder = NSLocalizedString(@"Please enter desc", @"text for image");;
	ctr.actionType = editDesc;
	ctr.modalPresentationStyle = UIModalPresentationCurrentContext;
	
	UINavigationController *navigationController =
	[[UINavigationController alloc] initWithRootViewController:ctr];
	
	[self presentViewController:navigationController animated:YES completion:nil];
	
//	__weak typeof (self) _self = self;
//	[Helper performBlock:^{
//		[_self presentViewController:navigationController animated:YES completion:nil];
//	} afterDelay:0.2];
}

- (void)saveDesc:(NSString *)desc {
	if(![[self currentEntity].desc isEqualToString:desc]) {
		[self currentEntity].desc = desc;
		[self.tableView reloadData];
	}
}

- (ArticleEntity *)entityForCell:(UITableViewCell *)cell {
	return [self entityForIndex:[self indexForCell:cell]];
}

- (ArticleEntity *)currentEntity {
	return [self entityForIndex:_indexInEditing];
}

- (NSInteger)indexForCell:(UITableViewCell *)cell {
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	_indexInEditing = indexPath.row;
	return _indexInEditing;
}

- (ArticleEntity *)entityForIndex:(NSInteger)index {
	return _dataArray[index];
}

#pragma mark - LFPhotoEdittingControllerDelegate
- (void)lf_PhotoEdittingController:(LFPhotoEdittingController *)photoEdittingVC didCancelPhotoEdit:(LFPhotoEdit *)photoEdit {
	[self dismissViewControllerAnimated:YES completion:nil];
//	[self.navigationController popViewControllerAnimated:YES];
}

- (void)lf_PhotoEdittingController:(LFPhotoEdittingController *)photoEdittingVC didFinishPhotoEdit:(LFPhotoEdit *)photoEdit {
	if(photoEdit) {
		[self currentEntity].image = photoEdit.editPreviewImage;
		[self.tableView reloadData];
	}
	[self dismissViewControllerAnimated:YES completion:nil];
//	[self.navigationController popViewControllerAnimated:YES];
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
	
	ArticleEntity *entity = _dataArray[indexPath.row];
	
	[cell setCellData:entity.image withDelegate:self];
	[cell setDescText:entity.desc];
	
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(tableView.editing) {
		return UITableViewCellEditingStyleInsert;
	}else {
		return UITableViewCellEditingStyleDelete;
	}
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		[_dataArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
		[_dataArray insertObject:[[ArticleEntity alloc]initWithImage:[UIImage imageNamed:@"1.jpeg"]] atIndex:indexPath.row];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
