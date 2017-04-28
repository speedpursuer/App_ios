//
//  ViewController.m
//  eService
//
//  Created by 邢磊 on 2017/4/11.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "CategoryTableViewController.h"
#import "LFImagePickerController.h"
#import "EditTableViewController.h"

@interface CategoryTableViewController () <LFImagePickerControllerDelegate>
@property (nonatomic, strong) NSMutableArray *categories;
@end

@implementation CategoryTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self configCrl];
	[self hideBackButtonText];
	// Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)configCrl {
	[self setTitle:NSLocalizedString(@"Service Catalog", @"Main page title")];
	_categories = [NSMutableArray arrayWithObjects:@"S1", @"S2", @"S3", nil];
}

- (void)hideBackButtonText {
	self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (IBAction)createNewService:(id)sender {
	LFImagePickerController *imagePicker = [[LFImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
	
	//    imagePicker.allowTakePicture = NO;
	imagePicker.sortAscendingByCreateDate = NO;
	imagePicker.doneBtnTitleStr = NSLocalizedString(@"OK", @"Confirm photo selection");
	imagePicker.allowEditting = NO;
	imagePicker.allowPickingOriginalPhoto = NO;
	[self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - Picker delegate
- (void)lf_imagePickerController:(LFImagePickerController *)picker didFinishPickingThumbnailImages:(NSArray<UIImage *> *)thumbnailImages originalImages:(NSArray<UIImage *> *)originalImages {
	
	EditTableViewController *ctr = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"edit1"];
	
//	ctr.images = originalImages;
	
	ctr.modalPresentationStyle = UIModalPresentationCurrentContext;
	
	UINavigationController *navigationController =
	[[UINavigationController alloc] initWithRootViewController:ctr];
	
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
//	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"category"];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"category" forIndexPath:indexPath];
	
	
	cell.textLabel.text = _categories[indexPath.row];
	
	cell.detailTextLabel.text = @"2";
	
	return cell;
}
@end
