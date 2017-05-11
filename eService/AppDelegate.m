//
//  AppDelegate.m
//  eService
//
//  Created by 邢磊 on 2017/4/11.
//  Copyright © 2017年 邢磊. All rights reserved.
//

#import "AppDelegate.h"
#import "WXApiManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


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

- (void)setupApp {
	[self setupTheme];
	[self setupWeixin];
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
@end
