//
//  EditTableViewCell.m
//  eService
//
//  Created by 邢磊 on 2017/4/11.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "EditTableViewCell.h"
#import <FontAwesomeKit/FAKIonIcons.h>
//#import "CALayer+YYAdd.h"

@interface EditTableViewCell ()
@property (weak, nonatomic) IBOutlet UIView *background;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (nonatomic, weak) id<EditArticle> delegate;
@end


@implementation EditTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
	[self setupButtons];
	[self addClickControlToImageView];
	[self addClickControlToTextView];
	
	[_desc.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
//	[_desc.layer setBorderWidth: 0.8];
//	[self.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
//	[self.layer setBorderWidth: 0.1];
//	[self.layer setCornerRadius: 2.0];
	
	_background.layer.borderColor = [[UIColor lightGrayColor] CGColor];
	_background.layer.borderWidth = 1.0;
	_background.layer.cornerRadius = 10.0;
//
//	self.selectedBackgroundView.backgroundColor = [UIColor lightGrayColor];
//	
    // Initialization code
}

- (void)setupButtons {
	CGSize size = CGSizeMake(25, 25);
	FAKIonIcons *icon1 = [FAKIonIcons iosCloseEmptyIconWithSize:30];
	[_deleteButton setTintColor:[UIColor lightGrayColor]];
	[_deleteButton setImage:[icon1 imageWithSize:size] forState:UIControlStateNormal];
	[_deleteButton setImage:[icon1 imageWithSize:size] forState:UIControlStateHighlighted];
}

- (void)addClickControlToImageView{
	
	_image.userInteractionEnabled = YES;
	
//	__weak typeof(_image) _view = _image;
//	__weak typeof(self) _self = self;
	
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
										 initWithTarget:self
										 action:@selector(editPhoto)];
	
	singleTap.numberOfTapsRequired = 1;
	
	[_image addGestureRecognizer:singleTap];
}

- (void)addClickControlToTextView{
	
	_desc.userInteractionEnabled = YES;
	
	//	__weak typeof(_image) _view = _image;
	//	__weak typeof(self) _self = self;
	
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
										 initWithTarget:self
										 action:@selector(editDesc)];
	
	singleTap.numberOfTapsRequired = 1;
	
	[_desc addGestureRecognizer:singleTap];
}

- (IBAction)deletePhoto:(id)sender {
	[_delegate deletePhoto:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellData:(UIImage *)image {
	_image.image = image;
}

- (void)setCellData:(NSString *)url desc:(NSString *)desc withDelegate:(id<EditArticle>)delegate {
//	_image.image = image;
	[_image requestImageWithURL:url];
	[self setDescText:desc];
	_delegate = delegate;
}

- (void)setCellData:(UIImage *)image url:(NSString *)url desc:(NSString *)desc withDelegate:(id<EditArticle>)delegate {
	if(image) {
		_image.image = image;
	}else {
		[_image requestImageWithURL:url];
	}
	
	[self setDescText:desc];
	_delegate = delegate;
}

- (void)setDescText:(NSString *)desc {
	if(desc.length == 0) {
		_desc.text = NSLocalizedString(@"Click to add desc", @"Add desc for image");
		_desc.textColor = [UIColor lightGrayColor];
	}else{
		_desc.text = desc;
		_desc.textColor = [UIColor blackColor];
	}
}

- (void)editPhoto {
//	UIViewAnimationOptions op = UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState;
//	[UIView animateWithDuration:0.1 delay:0 options:op animations:^{
//		_image.layer.transformScale = 0.97;
//	} completion:^(BOOL finished) {
//		[UIView animateWithDuration:0.1 delay:0 options:op animations:^{
//			_image.layer.transformScale = 1.008;
//		} completion:^(BOOL finished) {
//			[UIView animateWithDuration:0.1 delay:0 options:op animations:^{
//				_image.layer.transformScale = 1;
//			} completion:NULL];
//		}];
//	}];
	[_delegate editPhoto:self];
}

- (void)editDesc {
	[_delegate editDesc:self];
}

@end
