//
//  NineGridViewController.m
//  eService
//
//  Created by 邢磊 on 2017/5/7.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "NineGridViewController.h"
#import "UIImage+PECrop.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "MBProgressHUD.h"

@interface NineGridViewController ()
@property (weak, nonatomic) IBOutlet UIView *sampleView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *desc;
@property (nonatomic, strong) NSMutableArray *croppedImageMa;
@property MBProgressHUD *hud;
@end

@implementation NineGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setupConfig];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupConfig {
	_name.text = [Helper appName];
	_desc.text = @"朋友圈-九宫分图, 效果如下:";
	[self cropNineGridView];
}

#pragma makr - create nine grid

- (void)cropNineGridView {
	self.croppedImageMa = [NSMutableArray array];
	
	for (int i = 0; i < 3; i++) {
		for (int j = 0; j < 3; j++) {
			[self cropViewWithWith:j height:i];
		}
	}
}

- (void)cropViewWithWith:(CGFloat)w height:(CGFloat)h {
	CGFloat width = _didCropImage.size.width / 3.0f;
	CGFloat widthView = 80;
	CGFloat separtor = 3;
	
	CGRect rect = CGRectMake(width * w, width * h, width, width);
	UIImage *image = [_didCropImage rotatedImageWithtransform:CGAffineTransformIdentity croppedToRect:rect];
	NSLog(@"image = %@", image);
	[_croppedImageMa addObject:image];
	
	CGRect rectView = CGRectMake(60 + (widthView+separtor) * w, 60 + (widthView+separtor) * h, widthView, widthView);
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:rectView];
	imageView.image = image;
	NSLog(@"imageView = %@", imageView);
	[_sampleView addSubview:imageView];
}

#pragma mark - Action

- (IBAction)saveCroppedPicAction:(id)sender {
	if (_croppedImageMa.count) {
		_hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//		_hud.color = kAppColorMain;
		_hud.mode = MBProgressHUDModeIndeterminate;
		_hud.labelText = [NSString stringWithFormat:@"保存到相册..."];
		[self addHintImages];
		UIImage *image = _croppedImageMa[0];
		[self saveImageToAlbum:image index:0];
	}
}

- (void)addHintImages {
	[_croppedImageMa insertObject:[UIImage imageNamed:@"first"] atIndex:0];
	[_croppedImageMa insertObject:[UIImage imageNamed:@"last"] atIndex:_croppedImageMa.count];
}

- (void)saveImageToAlbum:(UIImage *)image index:(int)index{
	ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[assetsLibrary saveImage:image
						 toAlbum:[Helper appName]
			 withCompletionBlock:^(NSError *error) {
				 dispatch_async(dispatch_get_main_queue(), ^{
					 if (error) {
						 // 再保存此张
						 [self saveImageToAlbum:image index:index];
					 } else {
						 // 保存下一张
						 int idx = index+1;
						 if (idx < _croppedImageMa.count) {
							 UIImage *image = _croppedImageMa[idx];
							 [self saveImageToAlbum:image index:idx];
						 } else {
							 // 保存成功提示
							 UIImage *image = [UIImage imageNamed:@"success"];
							 UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
							 _hud.customView = imageView;
							 _hud.mode = MBProgressHUDModeCustomView;
							 _hud.labelText = @"保存成功!";
							 [_hud hide:YES afterDelay:1.f];
						 }
					 }
				 });
			 }];
	});
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
