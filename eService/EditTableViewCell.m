//
//  EditTableViewCell.m
//  eService
//
//  Created by 邢磊 on 2017/4/11.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "EditTableViewCell.h"
//#import "CALayer+YYAdd.h"

@interface EditTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UITextView *desc;
@property (nonatomic, weak) id<EditArticle> delegate;
@end


@implementation EditTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
	[self addClickControlToImageView];
	[self addClickControlToTextView];
//	[self.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
//	[self.layer setBorderWidth: 0.1];
//	[self.layer setCornerRadius: 2.0];
	
	_desc.layer.borderColor = [[UIColor lightGrayColor] CGColor];
	_desc.layer.borderWidth = 1.0;
//	_desc.layer.cornerRadius = 5.0;
	
    // Initialization code
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellData:(UIImage *)image {
	_image.image = image;
}

- (void)setCellData:(UIImage *)image withDelegate:(id<EditArticle>)delegate {
	_image.image = image;
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
