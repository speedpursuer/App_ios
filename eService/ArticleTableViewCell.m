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
@property (weak, nonatomic) IBOutlet UILabel *articleCount;
@end

@implementation ArticleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellData:(NSString *)thumbURL title:(NSString *)title count:(NSString *)count {
	[_thumb requestImageWithURL:thumbURL];
	_articleTitle.text = title;
	_articleCount.text = count;	
}

@end
