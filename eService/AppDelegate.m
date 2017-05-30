//
//  AppDelegate.m
//  eService
//
//  Created by 邢磊 on 2017/4/11.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "AppDelegate.h"
#import "WXApiManager.h"
#import <AdobeCreativeSDKCore/AdobeCreativeSDKCore.h>
#import <AdobeCreativeSDKImage/AdobeCreativeSDKImage.h>
//#import <imglyKit/imglyKit.h>
//#import <imglyKit/imglyKit-Swift.h>
//#import <QMapKit.h>
//#import <QMapSearchKit/QMapSearchKit.h>

@interface AppDelegate ()
@end

@implementation AppDelegate

//- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//	// Activate Photo Editor SDK license
//	[PESDK unlockWithLicenseAt:[[NSBundle mainBundle] URLForResource:@"license" withExtension:@""]];
//	
//	return YES;
//}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	[self setupApp];
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}

//- (UIInterfaceOrientationMask)application:(UIApplication *)application
//  supportedInterfaceOrientationsForWindow:(UIWindow *)window {
//	return UIInterfaceOrientationMaskPortrait;
//}

- (void)setupApp {
	[self setupTheme];
	[self setupWeixin];
	[self configEditor];
//	[self setupQMap];
}

- (void)setupTheme {
	[[UINavigationBar appearance] setTintColor: [UIColor whiteColor]];
	[[UINavigationBar appearance] setBarTintColor:APP_COLOR];
	[[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
	[[UINavigationBar appearance] setTranslucent:YES];
	//Segment control
//	[[UISegmentedControl appearance] setTintColor:CLIPLAY_COLOR];
//	[[UISlider appearance] setTintColor:CLIPLAY_COLOR];
//	[[UIButton appearance] setTintColor:CLIPLAY_COLOR];
}

- (void)setupWeixin {
	[WXApi registerApp:@"wx515ffccc2692d76d" enableMTA:YES];
}

- (void)configEditor {
	[[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:@"4da6f2e8f07b4a2284438ac00bde5267"
															   withClientSecret:@"261bb449-a8e2-4107-af64-e5de57c7bf41"];
//	[AdobeImageEditorOpenGLManager beginOpenGLLoad];
}


//- (void)setupQMap {
//	NSString *aipKey = @"EEQBZ-YXG3D-AL643-PPLVA-2GRW5-K6BQY";
////	[[QMapServices sharedServices] setApiKey:aipKey];
//	[[[QAppKeyCheck alloc] init] start:aipKey withDelegate:self];
////	[[QMSSearchServices sharedServices] setApiKey:aipKey];
//}

#pragma mark -  QAppKeyCheckDelegate
//- (void)notifyAppKeyCheckResult:(QErrorCode)errCode
//{
//	if(QErrorNone == errCode)
//		NSLog(@"Appkey check passed.");
//	else if(QNetError == errCode)
//		NSLog(@"QNetError");
//	else if(errCode == QAppKeyCheckFail)
//		NSLog(@"QAppKeyCheckFail");
//	else
//		return;
//}

@end
