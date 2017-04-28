//
//  AddCategoryViewController.m
//  eService
//
//  Created by 邢磊 on 2017/4/16.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "AddCategoryViewController.h"
#import "DEComposeTextView.h"

@interface AddCategoryViewController ()
@property (weak, nonatomic) IBOutlet DEComposeTextView *nameTextView;
@property (weak, nonatomic) IBOutlet DEComposeTextView *categoryName;

@end

@implementation AddCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[_categoryName becomeFirstResponder];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	_name = _categoryName.text;
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
