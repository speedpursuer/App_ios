//
//  ArticleHeader.m
//  eService
//
//  Created by 邢磊 on 2017/4/14.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "ArticleHeader.h"

@interface ArticleHeader()
@end

@implementation ArticleHeader

- (void)awakeFromNib {
	[super awakeFromNib];
	self.frame = CGRectMake(0, 0, self.frame.size.width, 160);
//	self.backgroundColor = [UIColor lightGrayColor];
//	_title.placeholder = NSLocalizedString(@"Please enter title", @"Article title");
//	_category.delegate = self;
//	_category.dataSource = self;
	// Initialization code
}

//#pragma mark Picker Delegate Methods
//-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
//	return 1;
//}
//
//-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
//	return [_pickerData count];
//}
//
//-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//	return [_pickerData objectAtIndex:row];
//}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
