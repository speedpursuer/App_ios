//
//  ShopSettingTableViewController.m
//  eService
//
//  Created by 邢磊 on 2017/5/17.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "ShopSettingTableViewController.h"
#import "DescViewController.h"
#import "ShopLocationViewController.h"
#import "TZImagePickerController.h"
//#import "VPImageCropperViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "TOCropViewController.h"

@interface ShopSettingTableViewController () <TZImagePickerControllerDelegate, TOCropViewControllerDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *phone;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBtn;
@property CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property Shop *shop;
@end

@implementation ShopSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self addClickControlToImageView];
	[self startStandardUpdates];
	[self setupData];
	[self setTitle];
	[self showHelpOverlay];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTitle {
	self.title = NSLocalizedString(@"Set Shop Info", @"设置门店信息");
}

- (void)showHelpOverlay {
	[[TipsService shared] showHelpType:ShopPhoto];
}

- (void)addClickControlToImageView{
	
	_avatar.userInteractionEnabled = YES;
	
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
										 initWithTarget:self
										 action:@selector(editPhoto:)];
	
	singleTap.numberOfTapsRequired = 1;
	
	[_avatar addGestureRecognizer:singleTap];
}

- (IBAction)editPhoto:(id)sender {	
	if(![_shop avatarImage]) return;
	[self showCropVCWithImage:_avatar.image];
}

- (void)dealloc {
	[_locationManager stopUpdatingLocation];
//	_locationManager = nil;
}

- (void)startStandardUpdates
{
	// Create the location manager if this object does not
	// already have one.
	if (nil == _locationManager)
	_locationManager = [[CLLocationManager alloc] init];
	_locationManager.delegate = self;
//	_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	[_locationManager startUpdatingLocation];
}

- (void)setupData {
	
	_shop = [[CBLService sharedManager] loadShop];
	_name.text = _shop.name;
	_address.text = _shop.address;
	_phone.text = _shop.phone;
	[_avatar requestImageWithURL:_shop.avatarURL completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
		if(image) _shop.avatar = image;
	}];
}

- (NSString *)stringWithEmpltytext:(NSString *)text {
	return text.length > 0? text: NSLocalizedString(@"Click to edit", @"Shop text edit");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"setShopName"]) {
		DescViewController *destViewController = segue.destinationViewController;
		destViewController.text = _name.text;
		destViewController.purpose = NSLocalizedString(@"Set Shop Name", @"setShopName");
		destViewController.saveDescHandle = ^(NSString *desc){
			_name.text = _shop.name = desc;
		};
	}
	
	if ([segue.identifier isEqualToString:@"setShopPhone"]) {
		DescViewController *destViewController = segue.destinationViewController;
		destViewController.text = _phone.text;
		destViewController.purpose = NSLocalizedString(@"Set Shop Phone", @"setShopName");
		destViewController.keyboardType = UIKeyboardTypePhonePad;
		destViewController.saveDescHandle = ^(NSString *desc){
			_phone.text = _shop.phone = desc;
		};
	}
	
	if ([segue.identifier isEqualToString:@"setShopAddress"]) {
		ShopLocationViewController *destViewController = segue.destinationViewController;
		destViewController.initLat = _shop.lat;
		destViewController.initLng = _shop.lng;
		destViewController.selectAddressHandle = ^(NSString *city, NSString *name, NSString *address, float lat, float lng){
			_address.text = _shop.address = address;
			_shop.lat = lat;
			_shop.lng = lng;
		};
	}
	
	if ([segue.identifier isEqualToString:@"setShopAvatar"]) {
		TZImagePickerController *destViewController = segue.destinationViewController;
		destViewController = [destViewController initWithMaxImagesCount:1 delegate:self];
		destViewController.allowPickingOriginalPhoto = NO;
		destViewController.allowPickingGif = NO;
		destViewController.allowPickingVideo = NO;
		destViewController.autoDismiss = NO;
	}
}

- (IBAction)saveShopSettings:(id)sender {
	if(sender == self.saveBtn) {
		if(![self isValidShop:_shop]) {
			[Helper showAlertMessage:NSLocalizedString(@"Please finish all fields", @"Shop info alert") withMessage:nil];
			return;
		}
		[[CBLService sharedManager] saveShop:_shop withAvatar:_avatar.image];
	}else {
		[_shop revertChanges];
	}
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showAlert:(id)sender {
	[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Exit?", @"放弃修改？") message:nil cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cacel") otherButtonTitles:NSLocalizedString(@"OK", @"OK") block:^(UIAlertView *alertView, NSInteger buttonIndex) {
		if (buttonIndex == 1) {
			[self saveShopSettings:_cancelBtn];
		}
	}] show];
}

- (BOOL)isValidShop:(Shop *)shop {
	if(shop.name.length > 0 && shop.phone.length > 0 && shop.address.length > 0) {
		return YES;
	}
	return NO;
}

#pragma mark - Picker delegate

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
	if(photos.count > 0) {
		[picker dismissViewControllerAnimated:NO completion:nil];
		[self showCropVCWithImage:photos[0]];
	}
}

- (void)showCropVCWithImage:(UIImage *)image {
	TOCropViewController *cropViewController = [[TOCropViewController alloc] initWithImage:image];
	cropViewController.delegate = self;
	[self presentViewController:cropViewController animated:YES completion:nil];
}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
	[picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - VPImageCropperDelegate

- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle {
	_avatar.image = _shop.avatar = image;
	[self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
	// 'image' is the newly cropped version of the original image
}

//- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
//	_avatar.image = editedImage;
//	[cropperViewController dismissViewControllerAnimated:YES completion:nil];
////	[self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
//}
//
//- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
//	[cropperViewController dismissViewControllerAnimated:YES completion:nil];
//}


//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
