//
//  DescViewController.m
//  eService
//
//  Created by 邢磊 on 2017/4/13.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "DescViewController.h"
#import "DEComposeTextView.h"

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
		_descView.text = _text;
	}
	[_descView setPlaceholder:_descPlaceholder];
	[_descView becomeFirstResponder];
}

- (void)setupThumb {
	_thumbView.contentMode = UIViewContentModeScaleAspectFill;
	_thumbView.layer.masksToBounds = YES;
	_thumbView.image = _image;
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
//		[_delegate saveDesc:_descView.text];
		if(_actionType == editTitle) {
			[_delegate saveTitle:_descView.text];
		}
		if(_actionType == editDesc){
			[_delegate saveDesc:_descView.text];
		}
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
