//
//  ArticleHeaderTableViewCell.m
//  eService
//
//  Created by 邢磊 on 2017/6/2.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "ArticleHeaderTableViewCell.h"

@implementation ArticleHeaderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
	[self setupBtn];
	[self addClickControl];
    // Initialization code
}

- (void)setupBtn {
	FAKIonIcons *icon = [FAKIonIcons iosLocationIconWithSize:14];
	[_locBtn setImage:[icon imageWithSize:CGSizeMake(14, 14)] forState:UIControlStateNormal];
}

- (void)addClickControl{
	
	_rest.userInteractionEnabled = YES;
	
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
										 initWithTarget:self
										 action:@selector(clickRest:)];
	
	singleTap.numberOfTapsRequired = 1;
	
	[_rest addGestureRecognizer:singleTap];
}

- (IBAction)clickRest:(id)sender {
	if(_clickLocHandle) _clickLocHandle();
}

- (void)configHeader:(NSString *)title date:(NSString *)date restName:(NSString *)name{	
	if(!name) _locBtn.hidden = YES;
	_headTitle.text = title;
	_rest.text = name;
	_date.text = date;
}


@end
