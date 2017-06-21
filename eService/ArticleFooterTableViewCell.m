//
//  ArticleHeaderTableViewCell.m
//  eService
//
//  Created by 邢磊 on 2017/6/2.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "ArticleFooterTableViewCell.h"

@implementation ArticleFooterTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
	[self setupBtn];
	[self addClickControl];
    // Initialization code
}

- (void)setupBtn {
	FAKIonIcons *icon = [FAKIonIcons iosLocationIconWithSize:14];
	[_addIcon setImage:[icon imageWithSize:CGSizeMake(14, 14)] forState:UIControlStateNormal];
	
	icon = [FAKIonIcons iosTelephoneIconWithSize:14];
	[_telIcon setImage:[icon imageWithSize:CGSizeMake(14, 14)] forState:UIControlStateNormal];
}

- (void)addClickControl{
	
	_address.userInteractionEnabled = YES;
	
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
										 initWithTarget:self
										 action:@selector(clickAddress:)];
	
	singleTap.numberOfTapsRequired = 1;
	
	[_address addGestureRecognizer:singleTap];
	
	_tel.userInteractionEnabled = YES;
	
	singleTap = [[UITapGestureRecognizer alloc]
										 initWithTarget:self
										 action:@selector(clickTel:)];
	
	singleTap.numberOfTapsRequired = 1;
	
	[_tel addGestureRecognizer:singleTap];
}

- (IBAction)clickAddress:(id)sender {
	if(_clickAddressHandle) _clickAddressHandle();
}

- (IBAction)clickTel:(id)sender {
	 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", _tel.text]]];
}

- (void)configShopName:(NSString *)shopName tel:(NSString *)tel address:(NSString *)address{
	_shopName.text = [NSString stringWithFormat:@"「%@」", shopName];
	_tel.text = tel;
	_address.text = address;
}


@end
