//
//  ArticleDisplayTableViewController.m
//  eService
//
//  Created by 邢磊 on 2017/4/16.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "ArticleDisplayTableViewController.h"
//#import "ArticleDisplayTableViewCell.h"
#import "ArticleTextTableViewCell.h"
#import "ArticlePhotoTableViewCell.h"
#import "ArticleEntry.h"
//#import "UITableView+FDTemplateLayoutCell.h"

#define photoWidth ([[UIScreen mainScreen] bounds].size.width - 2 * 8)

@interface ArticleDisplayTableViewController ()
@property NSArray *dataArray;
@end

@implementation ArticleDisplayTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self processData];
	[self configTableView];
	[self configHeader];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)processData {
	NSMutableArray *array = [NSMutableArray new];
	for(ArticleEntry *entry in _article.entryList) {
		if([self hasDescInEntry:entry]) {
			[array addObject:entry.desc];
		}
		
		if([self hasPhotoInEntry:entry]) {
			ArticleEntry *newEntry = [[ArticleEntry alloc] initWithImageURL:entry.imageURL withSize:entry.size];
			[array addObject:newEntry];
		}		
	}
	_dataArray = [array copy];
}

-(void)configTableView {
	[self.tableView registerNib: [UINib nibWithNibName:@"ArticleTextTableViewCell" bundle:nil] forCellReuseIdentifier:@"text"];
	
	[self.tableView registerNib: [UINib nibWithNibName:@"ArticlePhotoTableViewCell" bundle:nil] forCellReuseIdentifier:@"photo"];

	
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	self.tableView.estimatedRowHeight = 400;
	self.title = _article.title;
}

-(void)configHeader {
	ArticleEntry *firstEntry = _article.entryList.firstObject;
	if(![self hasDescInEntry:firstEntry]) {
		UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 8)];
		[self.tableView setTableHeaderView:headerView];
	}
}

-(BOOL)hasPhotoInEntry:(ArticleEntry *)entry {
	return entry.imageURL.length > 0? YES: NO;
}

-(BOOL)hasDescInEntry:(ArticleEntry *)entry {
	return entry.desc.length > 0? YES: NO;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell <ArticleTableViewCell> *cell;
	
	id rowData = _dataArray[indexPath.row];
	
	if([self isPhotoCellWithRowData:rowData]) {
		ArticleEntry *entry = (ArticleEntry *)rowData;
		cell = [tableView dequeueReusableCellWithIdentifier:@"photo" forIndexPath:indexPath];
		[cell setCellData:entry.imageURL desc:nil];
	}else {
		cell = [tableView dequeueReusableCellWithIdentifier:@"text" forIndexPath:indexPath];
		[cell setCellData:nil desc:rowData];
	}
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	id rowData = _dataArray[indexPath.row];
	
	if([self isPhotoCellWithRowData:rowData]) {
//		UIImage *image = _dataArray[indexPath.row];
//		CGFloat height = image.size.height * (photoWidth / image.size.width);
//		return height + 8;
		
//		return UITableViewAutomaticDimension;
		
		ArticleEntry *entry = (ArticleEntry *)rowData;
		return entry.size.height * (photoWidth / entry.size.width) + 8;
	}else {
		return UITableViewAutomaticDimension;
	}
}

-(BOOL)isPhotoCellWithRowData:(id)rowData{
	return [rowData isKindOfClass:[ArticleEntry class]]? YES: NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	
//	id rowData = _dataArray[indexPath.row];
//	
//	if([rowData isKindOfClass:[NSString class]]) {
////		NSString *cellText = rowData;
//////		UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
////		
////		UIFont *cellFont = [UIFont systemFontOfSize:17.0];
////		
////		CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
////		CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
////		
////		return labelSize.height;
//////		return 400;
//		
//		return [tableView fd_heightForCellWithIdentifier:@"text" cacheByIndexPath:indexPath configuration:^(UITableViewCell <ArticleTableViewCell> *cell) {
////			cell = [tableView dequeueReusableCellWithIdentifier:@"text" forIndexPath:indexPath];
//			[cell setCellData:nil desc:rowData];
//		}];
//	}
//	
//	if([rowData isKindOfClass:[UIImage class]]) {
//		UIImage *image = _dataArray[indexPath.row];
//		CGFloat height = image.size.height * (photoWidth / image.size.width);
//		return height + 8;
//	}
//	
//	return 0;
//}


//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	UITableViewCell <ArticleTableViewCell> *cell;
//	id rowData = _dataArray[indexPath.row];
//	
//	if([rowData isKindOfClass:[NSString class]]) {
//		cell = [tableView dequeueReusableCellWithIdentifier:@"text" forIndexPath:indexPath];
////		[cell setCellData:nil desc:rowData];
//	}
//	
//	if([rowData isKindOfClass:[UIImage class]]) {
//		cell = [tableView dequeueReusableCellWithIdentifier:@"photo" forIndexPath:indexPath];
//		
//		//		UIImage *image = rowData;
//		//
//		//		if(image.size.width > 304) {
//		//			image = [image resizeToSize:(CGSizeMake(304, image.size.height * (304 / image.size.width)))];
//		//		}
//		
////		[cell setCellData:rowData desc:nil];
//	}
//	return [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1;
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
