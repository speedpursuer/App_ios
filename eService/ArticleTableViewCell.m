//
//  ArticleTableViewCell.m
//  eService
//
//  Created by 邢磊 on 2017/4/16.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "ArticleTableViewCell.h"

@interface ArticleTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *thumb;
@property (weak, nonatomic) IBOutlet UILabel *articleTitle;
@property (weak, nonatomic) IBOutlet UILabel *rest;
@property (weak, nonatomic) IBOutlet UILabel *date;
@end

@implementation ArticleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
	[[_thumb layer] setCornerRadius:10.0];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellData:(NSString *)thumbURL title:(NSString *)title restName:(NSString *)name date:(NSString *)date {
	[_thumb requestImageWithURL:thumbURL];
	_articleTitle.text = title;
	_rest.text = name;
	_date.text = date;
}

@end
