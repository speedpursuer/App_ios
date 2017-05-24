//
//  DescViewController.m
//  eService
//
//  Created by 邢磊 on 2017/4/13.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "DescViewController.h"
#import "DEComposeTextView.h"
#import "UIImage+Resize.h"
#import "MWPhotoBrowser.h"

@interface DescViewController () <MWPhotoBrowserDelegate>
@property (weak, nonatomic) IBOutlet DEComposeTextView *descView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *confirmButton;
@property MWPhoto *photo;
@end

@implementation DescViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self loadUI];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadUI {
	[self hideBackButtonText];
	[self setupThumb];
	[self setupDesc];
//	[self setupButton];
	[self addClickControlToImageView];
	[self setupOthers];
}

- (void)hideBackButtonText {
	self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)setupDesc {
	if(_text) {
//		_descView.text = _text;
		
		UIFont *systemFont = [UIFont systemFontOfSize:18.0f];
		
		NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:systemFont
																	forKey:NSFontAttributeName];
		
		NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_text attributes:attrsDictionary];
		NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
		paragraphStyle.lineSpacing = 5;
		paragraphStyle.paragraphSpacingBefore = 6;
		//	paragraphStyle.firstLineHeadIndent = 30;
		[attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, _text.length)];
		
		_descView.attributedText = attributedString;
	}
	[_descView setPlaceholder:_descPlaceholder];
	[_descView becomeFirstResponder];
}

- (void)setupThumb {
	_thumbView.contentMode = UIViewContentModeScaleAspectFit;
	_thumbView.layer.masksToBounds = NO;
	
	if(_image) {
		_thumbView.image = _image;
		NSLayoutConstraint* constraint1 = [NSLayoutConstraint constraintWithItem: _thumbView
																	   attribute: NSLayoutAttributeWidth
																	   relatedBy: NSLayoutRelationEqual
																		  toItem: _thumbView
																	   attribute: NSLayoutAttributeHeight
																	  multiplier: _image.size.width/_image.size.height
																		constant: 0];
		NSLayoutConstraint* constraint2 = [NSLayoutConstraint constraintWithItem: _thumbView
																	  attribute: NSLayoutAttributeWidth
																	  relatedBy: NSLayoutRelationEqual
																		 toItem: nil
																	  attribute: NSLayoutAttributeNotAnAttribute
																	 multiplier: 0
																	   constant: 120];
		[_thumbView addConstraint: constraint1];
		[_thumbView addConstraint: constraint2];
	}else {
		NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem: _thumbView
												  attribute: NSLayoutAttributeWidth
												  relatedBy: NSLayoutRelationEqual
													 toItem: nil
												  attribute: NSLayoutAttributeNotAnAttribute
												 multiplier: 0
												   constant: 0];
		[_thumbView addConstraint: constraint];
	}
	
	_photo = [MWPhoto photoWithImage:_image];
	_photo.caption = _text;
}

//- (void)setupButton {
//	if(_actionType == sendClip) {
//		_confirmButton.title = NSLocalizedString(@"Send", @"Share to weibo");
//	}else{
//		_confirmButton.title = NSLocalizedString(@"Save", @"clip edit");
//	}
//}

- (void)setupOthers {
//	if(_actionType == editDesc) {
//		self.title = NSLocalizedString(@"Edit Comment", @"clip edit");
//	}else {
//		self.title = NSLocalizedString(@"Add Comment", @"clip edit");
//	}
	
	self.title = _purpose.length == 0? NSLocalizedString(@"Add Comment", @"clip edit"): _purpose;
	_descView.keyboardType = _keyboardType? _keyboardType: UIKeyboardTypeDefault;
}

- (IBAction)goBack:(id)sender {
	[self.view endEditing:YES];
	if(sender == self.confirmButton) {
		_saveDescHandle(_descView.text);
//		[_delegate saveDesc:_descView.text];
//		if(_actionType == editTitle) {
//			[_delegate saveTitle:_descView.text];
//		}
//		if(_actionType == editDesc){
//			[_delegate saveDesc:_descView.text];
//		}
	}
	[self.navigationController popViewControllerAnimated:YES];
//	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addClickControlToImageView{
	
	_thumbView.userInteractionEnabled = YES;
	
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
										 initWithTarget:self
										 action:@selector(showPhotoBrowser)];
	
	singleTap.numberOfTapsRequired = 1;
	
	[_thumbView addGestureRecognizer:singleTap];
}

-(void)showPhotoBrowser {
	
	_photo.caption = _descView.text;
	
	MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
	browser.displayActionButton = NO;
	//	browser.displayNavArrows = YES;
	//	browser.displaySelectionButtons = displaySelectionButtons;
	//	browser.alwaysShowControls = YES;
	browser.zoomPhotosToFill = YES;
	//	browser.enableGrid = enableGrid;
	//	browser.startOnGrid = startOnGrid;
	browser.enableSwipeToDismiss = NO;
	//	browser.autoPlayOnAppear = autoPlayOnAppear;
	[browser setCurrentPhotoIndex:0];
	
	[self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
	return 1;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
	return _photo;
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
