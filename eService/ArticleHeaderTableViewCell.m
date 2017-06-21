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
    // Initialization code
}

- (void)configTitle:(NSString *)title count:(NSInteger)count{
	_headTitle.text = title;
	[self updateCount:count];
}

- (void)updateCount:(NSInteger)count {
	if(count != -1) {
		_count.text = [NSString stringWithFormat:@"%@ %ld %@", NSLocalizedString(@"Read", @"阅读"), (long)count, NSLocalizedString(@"Times", @"次")];
	}else {
		_count.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Read", @"阅读"), NSLocalizedString(@"Times", @"次")];
	}
}

@end
