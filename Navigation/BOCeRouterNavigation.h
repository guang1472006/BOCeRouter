//
//  BOCeRouterNavigation.h
//  ss
//
//  Created by boce on 2019/9/9.
//  Copyright © 2019 boce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BOCeRouterNavigation : NSObject

/**
 Whether TabBar automatically hide when push
 
 @param hide Whether to automatically hide, the default is NO
 */
+ (void)autoHidesBottomBarWhenPushed:(BOOL)hide;



/**
 Get current ViewController
 
 @return Current ViewController
 */
+ (UIViewController *_Nullable)currentViewController;

/**
 Get current NavigationViewController
 
 @return return Current NavigationViewController
 */
+ (nullable UINavigationController *)currentNavigationViewController;



/**
 Push ViewController
 
 @param viewController Target ViewController
 @param animated Whether to use animation
 */
+ (void)pushViewController:(UIViewController *_Nullable)viewController animated:(BOOL)animated;

/**
 Push ViewController，can set whether the current ViewController is still reserved.
 
 @param viewController Target ViewController
 @param replace whether the current ViewController is still reserved
 @param animated Whether to use animation
 */
+ (void)pushViewController:(UIViewController *_Nullable)viewController replace:(BOOL)replace animated:(BOOL)animated;

/**
 Push multiple ViewController
 
 @param viewControllers ViewController Array
 @param animated Whether to use animation
 */
+ (void)pushViewControllerArray:(NSArray *_Nullable)viewControllers animated:(BOOL)animated;

/**
 present ViewController
 
 @param viewController Target ViewController
 @param animated Whether to use animation
 @param completion Callback
 */
+ (void)presentViewController:(UIViewController *_Nullable)viewController animated:(BOOL)animated completion:(void (^ __nullable)(void))completion;



/**
 Close the current ViewController, push, present universal
 
 @param animated Whether to use animation
 */
+ (void)closeViewControllerAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
