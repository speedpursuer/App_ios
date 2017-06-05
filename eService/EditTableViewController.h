//
//  EditTableViewController.h
//  eService
//
//  Created by 邢磊 on 2017/4/11.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditTableViewController : UITableViewController
@property (nonatomic, strong) NSArray<UIImage *> *images;
@property (nonatomic, strong) NSArray<NSDictionary *> *imageInfos;
@property (nonatomic, strong) Article *article;
@end
