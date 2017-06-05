//
//  ArticleDisplayHeader.m
//  eService
//
//  Created by 邢磊 on 2017/5/30.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "ArticleDisplayHeader.h"
@interface ArticleDisplayHeader ()

@end
@implementation ArticleDisplayHeader

- (void)awakeFromNib {
	[super awakeFromNib];
	self.frame = CGRectMake(0, 0, self.frame.size.width, 100);
	[self setupBtn];
//	[self resizeHeight];
}

- (void)setupBtn {
	FAKIonIcons *icon = [FAKIonIcons iosLocationIconWithSize:14];
	[_locBtn setImage:[icon imageWithSize:CGSizeMake(14, 14)] forState:UIControlStateNormal];
}

//- (void)layoutSubviews {
//	[super layoutSubviews];
//	self.title.preferredMaxLayoutWidth = CGRectGetWidth(self.bounds);
//	[super layoutSubviews];
//}

- (CGSize)intrinsicContentSize {
	CGFloat height = self.title.bounds.size.height;
	height += 50;
	height += self.date.bounds.size.height;
	CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width, height);
	return size;
}

- (void)resizeHeight {
	NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem: self
																   attribute: NSLayoutAttributeBottom
																   relatedBy: NSLayoutRelationEqual
																	  toItem: _date
																   attribute: NSLayoutAttributeBottom
																  multiplier: 1
																	constant: 10];
	[self addConstraint: constraint];
}

- (void)configHeader:(NSString *)title date:(NSString *)date restName:(NSString *)name{
//	[self setTranslatesAutoresizingMaskIntoConstraints:NO];
	if(!name) _locBtn.hidden = YES;
	_title.text = title;
	_rest.text = name;
	_date.text = date;
//	[self layoutIfNeeded];
//	[self invalidateIntrinsicContentSize];
	
//	[self sizeToFit];
//	self.frame = CGRectMake(0, 0, self.frame.size.width, _date.frame.origin.y + _date.frame.size.height + 10);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
