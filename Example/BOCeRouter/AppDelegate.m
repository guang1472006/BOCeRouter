//
//  AppDelegate.m
//  BOCeRouter
//
//  Created by boce on 2021/1/8.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "MyViewController.h"
#import "BaseViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Home
    HomeViewController *vc=[[HomeViewController alloc]init];
    BaseViewController *nav=[[BaseViewController alloc]initWithRootViewController:vc];
    nav.tabBarItem.title=@"Home";
    
    //My
    MyViewController *my=[[MyViewController alloc]init];
    BaseViewController *myNav=[[BaseViewController alloc]initWithRootViewController:my];
    myNav.tabBarItem.title=@"my";
    
    //tabbar
    UITabBarController *tabbar=[[UITabBarController alloc]init];
    tabbar.viewControllers=@[nav,myNav];
    //window
    self.window.rootViewController=tabbar;
    
    return YES;
}

@end
