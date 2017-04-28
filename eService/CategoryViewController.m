//
//  CategoryViewController.m
//  eService
//
//  Created by 邢磊 on 2017/4/16.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "CategoryViewController.h"
#import "AddCategoryViewController.h"

@interface CategoryViewController () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end

@implementation CategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self configCtrl];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configCtrl {
	_picker.dataSource = self;
	_picker.delegate = self;
}

//- (IBAction)goBack:(id)sender {
//	[self.navigationController popViewControllerAnimated:YES];
////	[self dismissViewControllerAnimated:YES completion:nil];
//}

- (IBAction)unwindBack:(UIStoryboardSegue *)segue {
	AddCategoryViewController *source = [segue sourceViewController];
	NSMutableArray *newArray = [NSMutableArray arrayWithArray:_dataArray];
	[newArray addObject:source.name];
	_dataArray = [newArray copy];
	[_picker reloadAllComponents];
	[_picker selectRow:[_picker numberOfRowsInComponent:0] - 1 inComponent:0 animated:YES];
	_selectedCategory = source.name;
}

#pragma mark Picker Delegate Methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//	return NSLocalizedString(@"Choose Category", @"title for category");
//}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return _dataArray.count;
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [_dataArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	_selectedCategory = [_dataArray objectAtIndex:row];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
