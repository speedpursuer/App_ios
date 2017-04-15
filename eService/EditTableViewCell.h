//
//  EditTableViewCell.h
//  eService
//
//  Created by 邢磊 on 2017/4/11.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditArticle <NSObject>

//- (void)editPhoto:(NSInteger)index;
- (void)editDesc:(UITableViewCell *)cell;

- (void)editPhoto:(UITableViewCell *)cell;

@end

@interface EditTableViewCell : UITableViewCell
- (void)setCellData:(UIImage *)image;
- (void)setCellData:(UIImage *)image withDelegate:(id<EditArticle>)delegate;
- (void)setDescText:(NSString *)desc;
@end

