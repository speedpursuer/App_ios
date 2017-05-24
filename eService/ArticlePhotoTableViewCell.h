//
//  ArticlePhotoTableViewCell.h
//  eService
//
//  Created by 邢磊 on 2017/4/17.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticlePhotoTableViewCell : UITableViewCell
@property (nonatomic, copy) void (^clickImageHandle)(NSInteger index);
- (void)setCellData:(NSString *)url desc:(NSString *)desc;
- (void)setCellData:(NSString *)url photoIndex:(NSInteger)index;
@end
