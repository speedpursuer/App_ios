//
//  ArticleDisplayTableViewCell.m
//  eService
//
//  Created by 邢磊 on 2017/4/16.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "ArticleDisplayTableViewCell.h"

@implementation ArticleDisplayTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellData:(UIImage *)photo desc:(NSString *)desc {
	_photo.image = photo;
	_desc.text = desc;
	[self layoutIfNeeded];
}

@end
