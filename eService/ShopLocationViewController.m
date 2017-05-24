//
//  ShopLocationViewController.m
//  eService
//
//  Created by 邢磊 on 2017/5/16.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "ShopLocationViewController.h"
#import "WebViewJavascriptBridge.h"

@interface ShopLocationViewController () <UIWebViewDelegate>
@property WebViewJavascriptBridge* bridge;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBtn;
@property NSString *city;
@property NSString *name;
@property NSString *address;
@property float lat;
@property float lng;
@end

@implementation ShopLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self loadWebView];
    // Do any additional setup after loading the view.
}

//- (void)viewWillAppear:(BOOL)animated {
//	if (_bridge) { return; }
//	[self loadWebView];
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadWebView {
	
//	[WebViewJavascriptBridge enableLogging];
	
	UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:webView];
	
	self.bridge = [WebViewJavascriptBridge bridgeForWebView:webView];
	
	[_bridge setWebViewDelegate:self];
	
	[self.bridge registerHandler:@"ObjC Echo" handler:^(id data, WVJBResponseCallback responseCallback) {
		_city = [data objectForKey:@"city"];
		_name = [data objectForKey:@"name"];
		_address = [data objectForKey:@"address"];
		_lat = [[data objectForKey:@"lat"] floatValue];
		_lng = [[data objectForKey:@"lng"] floatValue];
	}];
	
	[self.bridge callHandler:@"JS Echo"
						data:@{
							   @"lat":_initLat?[[NSNumber numberWithFloat:_initLat] stringValue]:@"",
							   @"lng":_initLng?[[NSNumber numberWithFloat:_initLng] stringValue]:@""
							 }
	];
	
	webView.scrollView.bounces = NO;
	webView.scrollView.scrollEnabled = NO;
	
	NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"map" ofType:@"html"];
	NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
	[webView loadHTMLString:htmlString baseURL: [[NSBundle mainBundle] bundleURL]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	NSLog(@"webViewDidFinishLoad");
}

- (IBAction)saveSelection:(id)sender {
	if(sender == self.saveBtn) {
		if(_lat && _lng) {
			_selectAddressHandle(_city, _name, _address, _lat, _lng);
		}else {
			[Helper showAlertMessage:NSLocalizedString(@"Please select an address from the list", @"address alert") withMessage:nil];
			return;
		}
	}
	[self.navigationController popViewControllerAnimated:YES];
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
