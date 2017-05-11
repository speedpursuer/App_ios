//
//  ProgressHUD.m
//  eService
//
//  Created by 邢磊 on 2017/5/3.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "ProgressHUD.h"

@interface ProgressHUD ()
@property UIView *background;
@property UIButton *progressHUD;
@property UIView *HUDContainer;
@property UIActivityIndicatorView *HUDIndicatorView;
@property UILabel *HUDLabel;
@end

@implementation ProgressHUD

+ (ProgressHUD*)sharedInstance {
	static dispatch_once_t once;
	static ProgressHUD *sharedInstance;
	dispatch_once(&once, ^ {
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

+ (void)showInThread {
	[Helper performBlock:^{
		[[self sharedInstance] showProgressHUD];
	} afterDelay:0.1];
}

+ (void)hideInThread {
	[Helper performBlock:^{
		[[self sharedInstance] hideProgressHUD];
	} afterDelay:0.1];
}

+ (void)show {
	[[self sharedInstance] showProgressHUD];
}

+ (void)hide {
	[[self sharedInstance] hideProgressHUD];
}

- (void)showProgressHUD {
	if (!_progressHUD) {
		_background = [[UIView alloc]initWithFrame:CGRectMake(0, 0, UIScreenWidth, UIScreenHeight)];
		_background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_progressHUD = [UIButton buttonWithType:UIButtonTypeCustom];
		[_progressHUD setBackgroundColor:[UIColor clearColor]];
		
		_HUDContainer = [[UIView alloc] init];
		_HUDContainer.frame = CGRectMake((UIScreenWidth - 120) / 2, (UIScreenHeight - 90) / 2, 120, 90);
		_HUDContainer.layer.cornerRadius = 8;
		_HUDContainer.clipsToBounds = YES;
		_HUDContainer.backgroundColor = [UIColor darkGrayColor];
		_HUDContainer.alpha = 0.7;
		
		_HUDIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		_HUDIndicatorView.frame = CGRectMake(45, 15, 30, 30);
		
		_HUDLabel = [[UILabel alloc] init];
		_HUDLabel.frame = CGRectMake(0,40, 120, 50);
		_HUDLabel.textAlignment = NSTextAlignmentCenter;
		_HUDLabel.text = @"Processing";
		_HUDLabel.font = [UIFont systemFontOfSize:15];
		_HUDLabel.textColor = [UIColor whiteColor];
		
		[_HUDContainer addSubview:_HUDLabel];
		[_HUDContainer addSubview:_HUDIndicatorView];
		[_progressHUD addSubview:_HUDContainer];
		[_background addSubview:_progressHUD];
	}
	[_HUDIndicatorView startAnimating];
	[[UIApplication sharedApplication].keyWindow addSubview:_background];
	
	// if over time, dismiss HUD automatic
//	WeakSelf
//	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//		[weakSelf hideProgressHUD];
//	});
}

- (void)hideProgressHUD {
	if (_background) {
		[_HUDIndicatorView stopAnimating];
		[_background removeFromSuperview];
	}
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
