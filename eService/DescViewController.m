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

@interface DescViewController ()
@property (weak, nonatomic) IBOutlet DEComposeTextView *descView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *confirmButton;
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
	[self setupThumb];
	[self setupDesc];
//	[self setupButton];
	[self setupTitle];
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
}

//- (void)setupButton {
//	if(_actionType == sendClip) {
//		_confirmButton.title = NSLocalizedString(@"Send", @"Share to weibo");
//	}else{
//		_confirmButton.title = NSLocalizedString(@"Save", @"clip edit");
//	}
//}

- (void)setupTitle {
//	if(_actionType == editDesc) {
//		self.title = NSLocalizedString(@"Edit Comment", @"clip edit");
//	}else {
//		self.title = NSLocalizedString(@"Add Comment", @"clip edit");
//	}
	self.title = NSLocalizedString(@"Add Comment", @"clip edit");
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
