//
//  TAOOverlayHUD.m
//  Here a Story
//
//  Created by Or Sharir on 11/14/13.
//  Copyright (c) 2013 TAO Project. All rights reserved.
//

#import "TAOOverlayHelp.h"
#import "TAOArrowLayer.h"
#import "CGPointExtension.h"

typedef NS_ENUM(NSInteger, TipPosition) {
	Center,
	Bottom
};


@interface TAOOverlayHelp ()
@property (strong, nonatomic) TAOArrowLayer* arrowLayer;
@property (strong, nonatomic) UILabel * textLabel;
@property (strong, nonatomic) TAOOverlayHelpCompletionBlock didDismissBlock;
@property (strong, nonatomic) NSMutableArray* statusMessages;
@property (strong, nonatomic) NSMutableArray* pointAtArray;
@property (strong, nonatomic) NSMutableArray* didDismissBlockArray;
@property TipPosition position;
@end

@implementation TAOOverlayHelp

- (id)init {
	return [self initWithFrame:[[UIScreen mainScreen] bounds]];
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.userInteractionEnabled = YES;
		self.alpha = 0;
		self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
		//        self.translatesAutoresizingMaskIntoConstraints = NO;
		//        [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
		//        [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
		
		self.textLabel = [[UILabel alloc] init];
		self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
		self.textLabel.textAlignment = NSTextAlignmentCenter;
		self.textLabel.font = [UIFont systemFontOfSize:24];
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.textLabel.textColor = [UIColor whiteColor];
		self.textLabel.numberOfLines = 0;
		[self.textLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
		[self.textLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
		[self addSubview:self.textLabel];
		
		
		self.arrowLayer = [[TAOArrowLayer alloc] init];
		self.arrowLayer.frame = self.layer.bounds;
		self.arrowLayer.strokeColor = [UIColor whiteColor];
		self.arrowLayer.lineWidth = 3;
		[self.layer addSublayer:self.arrowLayer];
		
		self.statusMessages = [NSMutableArray array];
		self.pointAtArray = [NSMutableArray array];
		
		UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
		tap.numberOfTapsRequired = 1;
		tap.numberOfTouchesRequired = 1;
		[self addGestureRecognizer:tap];
	}
	return self;
}
- (void)setConstraints {
	NSLayoutConstraint* y;
	if(_position == Center) {
		y = [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
	}else {
		y = [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-50];
	}
	
	NSLayoutConstraint* centerX = [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
	NSLayoutConstraint* marginLeft = [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:60];
	NSLayoutConstraint* marginRight = [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:-60];
	//	NSLayoutConstraint* width = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:320];
	[self addConstraints:@[centerX, y, marginLeft, marginRight]];
	
	//    [super updateConstraints];
}
+ (BOOL)requiresConstraintBasedLayout {
	return YES;
}
- (CGSize)intrinsicContentSize {
	return [UIScreen mainScreen].bounds.size;
}
+ (TAOOverlayHelp*)sharedView {
	static dispatch_once_t once;
	static TAOOverlayHelp *sharedView;
	dispatch_once(&once, ^ {
		sharedView = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	});
	return sharedView;
}
+ (NSArray*)fillSuperviewConstraintsForView:(UIView*)view {
	if (!view.superview) {
		return @[];
	}
	NSArray* attributes = @[@(NSLayoutAttributeLeft), @(NSLayoutAttributeRight), @(NSLayoutAttributeTop), @(NSLayoutAttributeBottom)];
	NSMutableArray* constraints = [NSMutableArray arrayWithCapacity:attributes.count];
	for (NSNumber* attribute in attributes) {
		NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:view attribute:[attribute integerValue] relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:view.superview attribute:[attribute integerValue] multiplier:1 constant:0];
		[constraints addObject:constraint];
	}
	return [constraints copy];
}
- (void)didMoveToSuperview {
	[super didMoveToSuperview];
	//    if (self.superview) {
	//        [self.superview addConstraints:[TAOOverlayHelp fillSuperviewConstraintsForView:self]];
	//    }
}

- (BOOL)checkPoint:(CGPoint)point {
	CGFloat harf = self.frame.size.height / 2;
	if(point.y < 0 || point.y > self.frame.size.height) {
		return NO;
	}else {
		if(point.y > harf + 50 || point.y < harf - 50) {
			_position = Center;
		}else{
			_position = Bottom;
		}
		return YES;
	}
}

- (NSString*)showWithHelpTip:(NSString*)status pointAt:(CGPoint)point didDismiss:(TAOOverlayHelpCompletionBlock)didDismissBlock{
	if (!didDismissBlock) {
		didDismissBlock = ^{};
	}
	if (!status || status.length == 0 || ![self checkPoint:point]) {
		dispatch_async(dispatch_get_main_queue(), ^{
			didDismissBlock();
		});
		return nil;
	}
	
	[self setConstraints];
	[self setNeedsLayout];
	
	NSUInteger index = NSNotFound;
	if ([status isEqualToString:[self.statusMessages lastObject]]) {
		return status;
	} else if ((index = [self.statusMessages indexOfObject:status]) != NSNotFound) {
		[self.statusMessages removeObjectAtIndex:index];
		[self.pointAtArray removeObjectAtIndex:index];
		[self.didDismissBlockArray removeObjectAtIndex:index];
	}
	
	[self.statusMessages addObject:status];
	[self.pointAtArray addObject:[NSValue valueWithCGPoint:point]];
	
	[self.didDismissBlockArray addObject:didDismissBlock];
	
	[self showWithHelpTipInternal:status pointAt:point didDismiss:didDismissBlock];
	return status;
}

- (void)showWithHelpTipInternal:(NSString*)status pointAt:(CGPoint)point didDismiss:(TAOOverlayHelpCompletionBlock)didDismissBlock {
	if(!self.superview){
		NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication]windows]reverseObjectEnumerator];
		
		for (UIWindow *window in frontToBackWindows)
			if (window.windowLevel == UIWindowLevelNormal) {
				[window addSubview:self];
				break;
			}
	}
	
	self.textLabel.text = status;
	self.didDismissBlock = didDismissBlock;
	[self setNeedsUpdateConstraints];
	[self layoutIfNeeded];
	
	self.arrowLayer.end = point;
	
	CGPoint directionFromCenter;
	
	if(_position == Center) {
		directionFromCenter = CGPointSub(point, CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)));
	}else {
		directionFromCenter = CGPointSub(point, CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds) - 50));
	}
	
	double angle = CGPointToAngle(directionFromCenter);
	double byPointSign = 0;
	if (angle >= 0 && angle < M_PI_2) {
		self.arrowLayer.start = CGPointMake(CGRectGetMaxX(self.textLabel.frame), CGRectGetMaxY(self.textLabel.frame));
		byPointSign = -1;
	} else if (angle >= M_PI_2 && angle < M_PI) {
		self.arrowLayer.start = CGPointMake(CGRectGetMinX(self.textLabel.frame), CGRectGetMaxY(self.textLabel.frame));
		byPointSign = 1;
	} else if (angle < 0 && angle > -M_PI_2) {
		self.arrowLayer.start = CGPointMake(CGRectGetMaxX(self.textLabel.frame), CGRectGetMinY(self.textLabel.frame));
		byPointSign = 1;
	} else {
		self.arrowLayer.start = CGPointMake(CGRectGetMinX(self.textLabel.frame), CGRectGetMinY(self.textLabel.frame));
		byPointSign = -1;
	}
	
	CGPoint v = CGPointNormalize(CGPointRotateWithAngle(CGPointSub(self.arrowLayer.end, self.arrowLayer.start), M_PI_2));
	self.arrowLayer.by = CGPointAdd(CGPointMidpoint(self.arrowLayer.start, self.arrowLayer.end), CGPointMult(v, byPointSign*60));
	[self.arrowLayer updateDisplay];
	[self setNeedsDisplay];
	if(self.alpha != 1) {
		[UIView animateWithDuration:0.3
							  delay:0.1
							options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
						 animations:^{
							 
							 self.alpha = 1;
						 }
						 completion:^(BOOL finished){
							 UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
							 UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, status);
						 }];
		
		[self setNeedsDisplay];
	}
	
}
- (void)dismissInternal {
	[UIView animateWithDuration:0.15
						  delay:0
						options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 self.alpha = 0;
					 }
					 completion:^(BOOL finished){
						 if(self.alpha == 0) {
							 self.alpha = 0;
							 
							 [self removeFromSuperview];
							 
							 UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
							 
							 // Tell the rootViewController to update the StatusBar appearance
							 UIViewController *rootController = [[UIApplication sharedApplication] keyWindow].rootViewController;
							 if ([rootController respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
								 [rootController setNeedsStatusBarAppearanceUpdate];
							 }
						 }
					 }];
}
- (void)tapView:(UITapGestureRecognizer*)recognizer {
	if (recognizer.state == UIGestureRecognizerStateEnded) {
		[self dismiss];
	}
}
- (void)dismiss {
	[self.statusMessages removeLastObject];
	[self.pointAtArray removeLastObject];
	[self.didDismissBlockArray removeLastObject];
	TAOOverlayHelpCompletionBlock block = self.didDismissBlock;
	if (block) {
		self.didDismissBlock = nil;
		dispatch_async(dispatch_get_main_queue(), ^{
			block();
		});
	}
	if (self.statusMessages.count == 0 && [self isVisible]) {
		[self dismissInternal];
	}
	if (self.statusMessages.count > 0) {
		[self showWithHelpTip:[self.statusMessages lastObject] pointAt:[[self.pointAtArray lastObject] CGPointValue] didDismiss:[self.didDismissBlockArray lastObject]];
	}
}
- (void)dismiss:(NSString*)key {
	if (!key) return;
	NSUInteger index = [self.statusMessages indexOfObject:key];
	if (index == NSNotFound) return;
	[self.statusMessages removeObjectAtIndex:index];
	[self.pointAtArray removeObjectAtIndex:index];
	[self.didDismissBlockArray removeObjectAtIndex:index];
	TAOOverlayHelpCompletionBlock block = self.didDismissBlock;
	if (block) {
		self.didDismissBlock = nil;
		dispatch_async(dispatch_get_main_queue(), ^{
			block();
		});
	}
	if (self.statusMessages.count == 0 && [self isVisible]) {
		[self dismiss];
	}
	if (self.statusMessages.count > 0) {
		[self showWithHelpTip:[self.statusMessages lastObject] pointAt:[[self.pointAtArray lastObject] CGPointValue] didDismiss:[self.didDismissBlockArray lastObject]];
	}
}
- (BOOL)isVisible {
	return (self.alpha == 1);
}

@end
