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
//	_desc.text = desc;
	
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:desc];
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.lineSpacing = 8;
	paragraphStyle.paragraphSpacing = 8;
//	paragraphStyle.paragraphSpacingBefore = 9;
//	paragraphStyle.firstLineHeadIndent = 30;
	[attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, desc.length)];http://www.cocoachina.com/cms/uploads/allimg/140522/8369_140522110325_1.gif
	
	_desc.font = [UIFont fontWithName:@"PingFangSC-Regular" size:17];
	
	_desc.attributedText = attributedString;
	
	[self layoutIfNeeded];
}

//- (CGFloat)cellHeight {
//	return _desc.frame.size.height;
//}

@end
