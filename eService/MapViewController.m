//
//  MapViewController.m
//  eService
//
//  Created by 邢磊 on 2017/5/16.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "MapViewController.h"
#import <QMapKit.h>
#import <FontAwesomeKit/FAKIonIcons.h>

@interface MapViewController () <QMapViewDelegate>
@property (weak, nonatomic) IBOutlet QMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *navBtn;
@property QPointAnnotation *annotation;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self configMapView];
	[self configLocationBtn];
    // Do any additional setup after loading the view.
}

- (void)configMapView {
	self.mapView.delegate = self;
	_mapView.longPressedEnabled = YES;
	[_mapView setShowsUserLocation:YES];
	_mapView.userTrackingMode = QMUserTrackingModeFollow;
}

- (void)configLocationBtn {
	CGSize imageSize = CGSizeMake(30, 30);
	FAKIonIcons *icon = [FAKIonIcons navigateIconWithSize:30];
//	[icon addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor]];
	[_navBtn setImage:[icon imageWithSize:imageSize] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(QMapView *)mapView didUpdateUserLocation:(QUserLocation *)userLocation {
	dispatch_async(dispatch_get_main_queue(), ^{
		[_mapView setCenterCoordinate:userLocation.location
							zoomLevel:12.01 animated:NO];
	});
}

- (void)mapView:(QMapView *)mapView longPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
	[self addAnnotation:coordinate title:@"门店位置"];
}

- (void)addAnnotation:(CLLocationCoordinate2D)coordinate title:(NSString *)title {
	if(_annotation) [_mapView removeAnnotation:_annotation];
	
	_annotation = [[QPointAnnotation alloc] init];
	_annotation.title = title;
	_annotation.coordinate = coordinate;
 
	//向mapview添加annotation
	[_mapView addAnnotation:_annotation animated:YES];
	[_mapView selectAnnotation:_annotation animated:YES];
}

-(QAnnotationView *)mapView:(QMapView *)mapView viewForAnnotation:(id<QAnnotation>)annotation {
	static NSString *pointReuseIndentifier = @"pointReuseIdentifier";
	
	if ([annotation isKindOfClass:[QPointAnnotation class]]) {
		QPinAnnotationView *annotationView = (QPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
		if (annotationView == nil) {
			annotationView = [[QPinAnnotationView alloc]
							  initWithAnnotation:annotation
							  reuseIdentifier:pointReuseIndentifier];
		}
		//显示气泡，默认NO
		annotationView.canShowCallout = YES;
		//设置大头针颜色
		annotationView.pinColor = QPinAnnotationColorRed;
		//添加左侧信息窗附件
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
		FAKIonIcons *icon = [FAKIonIcons checkmarkIconWithSize:10];
		[btn setImage:[icon imageWithSize:CGSizeMake(10, 10)] forState:UIControlStateNormal];
		annotationView.leftCalloutAccessoryView = btn;
		annotationView.animatesDrop = YES;
		return annotationView;
	}
	return nil;
}

- (void)mapView:(QMapView *)mapView onClickedMapPoi:(QMapPoi*)mapPoi {
	[self addAnnotation:mapPoi.coordinate title:mapPoi.text];
}

- (IBAction)showUserLocation:(id)sender {
//	[self.mapView showsUserLocation:YES withMapCenter:YES];
	[_mapView setShowsUserLocation:YES];
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
