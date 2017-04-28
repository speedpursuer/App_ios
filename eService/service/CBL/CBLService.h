//
//  CBLService.h
//  eService
//
//  Created by 邢磊 on 2017/4/26.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBLService : NSObject
+ (id)sharedManager;
- (Article*)creatAlubmWithTitle:(NSString *) title category:(NSString *)category entryList:(NSArray *)entryList;
- (NSArray <Article *> *)loadArticles;
@end
