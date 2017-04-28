//
//  ArticleTextTableViewCell.m
//  eService
//
//  Created by 邢磊 on 2017/4/17.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "ArticleTextTableViewCell.h"
#import "ArticleDisplayTableViewController.h"

@interface ArticleTextTableViewCell()  <ArticleTableViewCell>
@property (weak, nonatomic) IBOutlet UILabel *desc;

@end

@implementation ArticleTextTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellData:(NSString *)url desc:(NSString *)desc {
	_desc.text = desc;
	[self layoutIfNeeded];
}

//- (CGFloat)cellHeight {
//	return _desc.frame.size.height;
//}

@end
