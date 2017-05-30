//
//  LFTagView.m
//  eService
//
//  Created by 邢磊 on 2017/5/28.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "LFTagView.h"
#import "YBTagHeader.h"

@interface LFTagView ()
@property YBTagView *tagView;
@end

@implementation LFTagView

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self customInit];
	}
	return self;
}

- (void)customInit {
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
	[self addGestureRecognizer:tapGestureRecognizer];

}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {

//	if ([event allTouches].count != 1) return;
	
	if(_tagView) [_tagView removeFromSuperview];
	
//	UITouch *touch = [touches anyObject];
//	CGPoint point = [touch locationInView:self];
	CGPoint point = [tapGestureRecognizer locationInView:tapGestureRecognizer.view];
	
	_tagView = [[YBTagView alloc]initWithPoint:point];
	_tagView.isClick = YES;
//	WS(weakSelf)
//	tagView.block = ^(NSString *TagwhichTag,CGPoint centerPoint,NSArray *dataArray){
//		SHOW_ALTER(TagwhichTag);
//	};
	[self addSubview:_tagView];
	_tagView.tagArray = @[@"回味无穷的葱油鸡"];//
//	tagView.tagArray = @[@"耐克",@"耐克air_plane"];//
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
