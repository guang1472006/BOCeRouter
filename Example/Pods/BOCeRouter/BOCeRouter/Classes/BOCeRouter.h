//
//  BOCeRouter.h
//  ss
//
//  Created by boce on 2019/9/9.
//  Copyright © 2019 boce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOCeRouterRewrite.h"
#import "BOCeRouterNavigation.h"

extern NSString * _Nullable const BOCeRouterParameterURLKey;

typedef void (^BOCeRouterHandler)(NSDictionary * _Nullable routerParameters);

typedef id _Nullable (^BOCeObjectRouterHandler)(NSDictionary * _Nullable routerParameters);

typedef void (^BOCeRouterCallback)(id _Nullable callbackObjc);

typedef void (^BOCeCallbackRouterHandler)(NSDictionary * _Nullable routerParameters,BOCeRouterCallback _Nullable targetCallback);

typedef void (^BOCeRouterUnregisterURLHandler)(NSString * _Nullable routerURL);

NS_ASSUME_NONNULL_BEGIN

@interface BOCeRouter : NSObject

/**
 Register URL,use it with 'routeURL:' and 'routeURL: withParameters:'.
 
 @param routeURL Registered URL
 @param handlerBlock Callback after route
 */
+ (void)registerRouteURL:(NSString *)routeURL handler:(BOCeRouterHandler)handlerBlock;

/**
 Register URL,use it with 'routeObjectURL:' and ‘routeObjectURL: withParameters:’,can return a Object.
 
 @param routeURL Registered URL
 @param handlerBlock Callback after route, and you can get a Object in this callback.
 */
+ (void)registerObjectRouteURL:(NSString *)routeURL handler:(BOCeObjectRouterHandler)handlerBlock;

/**
 Registered URL, use it with `routeCallbackURL: targetCallback:'and `routeCallback URL: withParameters: targetCallback:', calls back `targetCallback' asynchronously to return an Object
 
 @param routeURL Registered URL
 @param handlerBlock Callback after route,There is a `targetCallback' in `handlerBlock', which corresponds to the `targetCallback:' in `routeCallbackURL: targetCallback:'and `routeCallbackURL: withParameters: targetCallback:', which can be used for asynchronous callback to return an Object.
 */
+ (void)registerCallbackRouteURL:(NSString *)routeURL handler:(BOCeCallbackRouterHandler)handlerBlock;

/**
 Determine whether URL can be Route (whether it has been registered).
 
 @param URL URL to be verified
 @return Can it be routed
 */
+ (BOOL)canRouteURL:(NSString *)URL;

/**
 Route a URL
 
 @param URL URL to be routed
 */
+ (void)routeURL:(NSString *)URL;

/**
 Route a URL and bring additional parameters.
 
 @param URL URL to be routed
 @param parameters Additional parameters
 */
+ (void)routeURL:(NSString *)URL withParameters:(NSDictionary<NSString *, id> *)parameters;

/**
 Route a URL and get the returned Object
 
 @param URL URL to be routed
 @return Returned Object
 */
+ (id)routeObjectURL:(NSString *)URL;

/**
 Route a URL and bring additional parameters. get the returned Object
 
 @param URL URL to be routed
 @param parameters Additional parameters
 @return Returned Object
 */
+ (id)routeObjectURL:(NSString *)URL withParameters:(NSDictionary<NSString *, id> *)parameters;

/**
 Route a URL, 'targetCallBack' can asynchronously callback to return a Object.
 
 @param URL URL to be routed
 @param targetCallback asynchronous callback
 */
+ (void)routeCallbackURL:(NSString *)URL targetCallback:(BOCeRouterCallback)targetCallback;

/**
 Route a URL with additional parameters, and 'targetCallBack' can asynchronously callback to return a Object.
 
 @param URL URL to be routed
 @param parameters Additional parameters
 @param targetCallback asynchronous callback
 */
+ (void)routeCallbackURL:(NSString *)URL withParameters:(NSDictionary<NSString *, id> *)parameters targetCallback:(BOCeRouterCallback)targetCallback;

/**
 Route callback for an unregistered URL
 
 @param handler Callback
 */
+ (void)routeUnregisterURLHandler:(BOCeRouterUnregisterURLHandler)handler;

/**
 Cancel registration of a URL
 
 @param URL URL to be cancelled
 */
+ (void)unregisterRouteURL:(NSString *)URL;

/**
 Unregister all URL
 */
+ (void)unregisterAllRoutes;

/**
 Whether to display Log for debugging
 
 @param enable YES or NO.The default is NO
 */
+ (void)setLogEnabled:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
