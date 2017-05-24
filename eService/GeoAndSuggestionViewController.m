//
//  GeoAndSuggestionViewController.m
//  eService
//
//  Created by 邢磊 on 2017/5/15.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "GeoAndSuggestionViewController.h"
#import <QMapKit.h>
#import <QMapSearchKit/QMapSearchKit.h>
#import "PoiAnnotation.h"
//#import "PoiDetailViewController.h"

@interface GeoAndSuggestionViewController ()<UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, QMSSearchDelegate, QMapViewDelegate>

@property (nonatomic, strong) QMapView *mapView;

@property (nonatomic, strong) QMSSearcher *mapSearcher;

@property (nonatomic, strong) QMSSuggestionResult *suggestionResut;

@property (nonatomic, strong) QMSGeoCodeSearchResult *geoResult;

@end

@implementation GeoAndSuggestionViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	CGRect frame = self.view.frame;
	CGFloat searchBarHeight = self.searchDisplayController.searchBar.frame.size.height;
	frame.size.height -= searchBarHeight;
	frame.origin.y += searchBarHeight;
	self.mapView = [[QMapView alloc] initWithFrame:frame];
	self.mapView.delegate = self;
	[self.view insertSubview:self.mapView atIndex:0];
	
	self.searchDisplayController.searchResultsDataSource = self;
	self.searchDisplayController.searchResultsDelegate = self;
	
	self.mapSearcher = [[QMSSearcher alloc] initWithDelegate:self];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)fetchGeoData:(QMSSuggestionPoiData *)suggestionPoiData
{
	//配置搜索参数
	QMSGeoCodeSearchOption *geoOption = [[QMSGeoCodeSearchOption alloc] init];
	[geoOption setAddress:[suggestionPoiData address]];
	//    [geoOption setRegion:@"北京"];
	
	[self.mapSearcher searchWithGeoCodeSearchOption:geoOption];
}

- (void)setupAnnotation
{
	[self.mapView removeAnnotations:self.mapView.annotations];
	
	[self.mapView setCenterCoordinate:self.geoResult.location];
	
	PoiAnnotation *annotation = [[PoiAnnotation alloc] initWithPoiData:self.geoResult];
	[annotation setCoordinate:self.geoResult.location];
	[annotation setTitle:[NSString stringWithFormat:@"%@%@", self.geoResult.address_components.city, self.geoResult.address_components.district]];
	[annotation setSubtitle:[NSString stringWithFormat:@"%@%@", self.geoResult.address_components.street, self.geoResult.address_components.street_number]];
	//    [annotation setSubtitle:[NSString stringWithFormat:@"lat:%f, lng:%f", self.geoResult.location.latitude, self.geoResult.location.longitude]];
	[self.mapView addAnnotation:annotation];
}

#pragma mark - QMapView Delegate

- (void)mapView:(QMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	QAnnotationView *view = views[0];
	
	[self.mapView selectAnnotation:view.annotation animated:YES];
}

- (QAnnotationView *)mapView:(QMapView *)mapView viewForAnnotation:(id<QAnnotation>)annotation
{
	static NSString *reuseId = @"REUSE_ID";
	QPinAnnotationView *annotationView = (QPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
	
	if (nil == annotationView) {
		annotationView = [[QPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
	}
	
	annotationView.canShowCallout   = YES;
	annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	
	return annotationView;
}

- (void)mapView:(QMapView *)mapView annotationView:(QAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
//	QMSBaseResult *poi = [(PoiAnnotation *)view.annotation poiData];
//	PoiDetailViewController *vc = [[PoiDetailViewController alloc] initWithQMSResult:poi];
//	[vc setTitle:self.title];
//	[self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - QMSSearcher Delegate

- (void)searchWithSearchOption:(QMSSearchOption *)searchOption didFailWithError:(NSError *)error
{
	NSLog(@"error:%@", error);
}

- (void)searchWithSuggestionSearchOption:(QMSSuggestionSearchOption *)suggestionSearchOption didReceiveResult:(QMSSuggestionResult *)suggestionSearchResult
{
	NSLog(@"suggest result:%@", suggestionSearchResult);
	self.suggestionResut = suggestionSearchResult;
	[self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)searchWithGeoCodeSearchOption:(QMSGeoCodeSearchOption *)geoCodeSearchOption didReceiveResult:(QMSGeoCodeSearchResult *)geoCodeSearchResult
{
	NSLog(@"geo result:%@", geoCodeSearchResult);
	self.geoResult = geoCodeSearchResult;
	
	[self setupAnnotation];
}

#pragma mark - SearchDisplayController Delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	//配置搜索参数
	QMSSuggestionSearchOption *suggetionOption = [[QMSSuggestionSearchOption alloc] init];
	[suggetionOption setKeyword:searchString];
	//    [suggetionOption setRegion:@"北京"];
	
	[self.mapSearcher searchWithSuggestionSearchOption:suggetionOption];
	
	return NO;
}

#pragma mark - Search Result Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self fetchGeoData:[self.suggestionResut.dataArray objectAtIndex:[indexPath row]]];
	[self.searchDisplayController setActive:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.suggestionResut.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *reuseId = @"REUSE_ID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
	if (nil == cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseId];
	}
	
	QMSSuggestionPoiData *poi = [self.suggestionResut.dataArray objectAtIndex:[indexPath row
																			   ]];
	
	[cell.textLabel setText:poi.title];
	[cell.detailTextLabel setText:poi.address];
	
	return cell;
}

@end
