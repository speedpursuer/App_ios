//
//  ArticlePhotoTableViewCell.m
//  eService
//
//  Created by 邢磊 on 2017/4/17.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "ArticlePhotoTableViewCell.h"
#import "ArticleDisplayTableViewController.h"
#import "UIImage+Resize.h"

#define margin 8
#define photoWidth ([[UIScreen mainScreen] bounds].size.width - 2 * margin)


@interface ArticlePhotoTableViewCell() <ArticleTableViewCell>
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property NSInteger photoIndex;
@end

@implementation ArticlePhotoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
	[self addClickControlToImageView];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)addClickControlToImageView{
	
	_photo.userInteractionEnabled = YES;
	
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
										 initWithTarget:self
										 action:@selector(showPhotoBrowser:)];
	
	singleTap.numberOfTapsRequired = 1;
	
	
	[_photo addGestureRecognizer:singleTap];
	
	UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]
									   initWithTarget:self
									   action:@selector(showPhotoBrowser:)];
	
	[_photo addGestureRecognizer:pinch];
}

- (void)showPhotoBrowser:(UIGestureRecognizer *)sender {
	if ([sender isKindOfClass:[UIPinchGestureRecognizer class]] && sender.state != UIGestureRecognizerStateBegan) return;
	_clickImageHandle(_photoIndex);
}

- (void)setCellData:(NSString *)url desc:(NSString *)desc {
	
//	UIImage *image = photo;
//	
//	if(image.size.width > photoWidth) {
//		image = [image resizeToSize:(CGSizeMake(photoWidth, image.size.height * (photoWidth / image.size.width)))];
//	}
	[_photo requestImageWithNoPlaceholderWithURL:url];
//	[self layoutIfNeeded];
//	[self sizeToFit];
//	[self setNeedsUpdateConstraints];
//	[self updateConstraintsIfNeeded];
	
//	[_photo requestImageWithURL:url completion:^(UIImage * image, NSURL * url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
//		image = [image resizeToSize:(CGSizeMake(photoWidth, image.size.height * (photoWidth / image.size.width)))];
//		_photo.image = image;
//	}];
}

- (void)setCellData:(NSString *)url photoIndex:(NSInteger)index {
	_photoIndex = index;
	[_photo requestImageWithNoPlaceholderWithURL:url];
}

//- (CGSize)sizeThatFits:(CGSize)size {	
//	CGFloat height = _photo.frame.size.height * (photoWidth / _photo.frame.size.width ) + 8;
//	return CGSizeMake(self.frame.size.width, 20);
//}

//- (CGFloat)cellHeight {
//	return _photo.image.size.height * (photoWidth / _photo.image.size.width) + 2 * margin;
//}

@end
