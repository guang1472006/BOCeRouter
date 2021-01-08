//
//  BOCeRouter.m
//  ss
//
//  Created by boce on 2019/9/9.
//  Copyright © 2019 boce. All rights reserved.
//

#import "BOCeRouter.h"
#import "BOCeRouterLogger.h"

static NSString *const BOCeRouterWildcard = @"*";
static NSString *BOCeSpecialCharacters = @"/?&.";

static NSString *const BOCeRouterCoreKey = @"BOCeRouterCore";
static NSString *const BOCeRouterCoreBlockKey = @"BOCeRouterCoreBlock";
static NSString *const BOCeRouterCoreTypeKey = @"BOCeRouterCoreType";

NSString *const BOCeRouterParameterURLKey = @"BOCeRouterParameterURL";

typedef NS_ENUM(NSInteger,BOCeRouterType) {
    BOCeRouterTypeDefault = 0,
    BOCeRouterTypeObject = 1,
    BOCeRouterTypeCallback = 2,
};

@interface BOCeRouter ()

@property (nonatomic,strong) NSMutableDictionary *routes;

@property (nonatomic,strong) BOCeRouterUnregisterURLHandler routerUnregisterURLHandler;

@end

@implementation BOCeRouter

+ (instancetype)sharedInstance
{
    static BOCeRouter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - Public Methods
+ (void)registerRouteURL:(NSString *)routeURL handler:(BOCeRouterHandler)handlerBlock {
    BOCeRouterLog(@"registerRouteURL:%@",routeURL);
    [[self sharedInstance] addRouteURL:routeURL handler:handlerBlock];
}

+ (void)registerObjectRouteURL:(NSString *)routeURL handler:(BOCeObjectRouterHandler)handlerBlock {
    BOCeRouterLog(@"registerObjectRouteURL:%@",routeURL);
    [[self sharedInstance] addObjectRouteURL:routeURL handler:handlerBlock];
}

+ (void)registerCallbackRouteURL:(NSString *)routeURL handler:(BOCeCallbackRouterHandler)handlerBlock {
    BOCeRouterLog(@"registerCallbackRouteURL:%@",routeURL);
    [[self sharedInstance] addCallbackRouteURL:routeURL handler:handlerBlock];
}

+ (BOOL)canRouteURL:(NSString *)URL {
    NSString *rewriteURL = [BOCeRouterRewrite rewriteURL:URL];
    return [[self sharedInstance] achieveParametersFromURL:rewriteURL] ? YES : NO;
}

+ (void)routeURL:(NSString *)URL {
    [self routeURL:URL withParameters:@{}];
}

+ (void)routeURL:(NSString *)URL withParameters:(NSDictionary<NSString *, id> *)parameters {
    BOCeRouterLog(@"Route to URL:%@\nwithParameters:%@",URL,parameters);
    NSString *rewriteURL = [BOCeRouterRewrite rewriteURL:URL];
    URL = [rewriteURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSMutableDictionary *routerParameters = [[self sharedInstance] achieveParametersFromURL:URL];
    if(!routerParameters){
        BOCeRouterErrorLog(@"Route unregistered URL:%@",URL);
        [[self sharedInstance] unregisterURLBeRouterWithURL:URL];
        return;
    }
    
    [routerParameters enumerateKeysAndObjectsUsingBlock:^(id key, NSString *obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            routerParameters[key] = [NSString stringWithFormat:@"%@",obj];
        }
    }];
    
    if (routerParameters) {
        NSDictionary *coreDic = routerParameters[BOCeRouterCoreKey];
        BOCeRouterHandler handler = coreDic[BOCeRouterCoreBlockKey];
        BOCeRouterType type = [coreDic[BOCeRouterCoreTypeKey] integerValue];
        if (type != BOCeRouterTypeDefault) {
            [self routeTypeCheckLogWithCorrectType:type url:URL];
            return;
        }
        
        if (handler) {
            if (parameters) {
                [routerParameters addEntriesFromDictionary:parameters];
            }
            [routerParameters removeObjectForKey:BOCeRouterCoreKey];
            handler(routerParameters);
        }
    }
}

+ (id)routeObjectURL:(NSString *)URL {
    return [self routeObjectURL:URL withParameters:@{}];
}

+ (id)routeObjectURL:(NSString *)URL withParameters:(NSDictionary<NSString *, id> *)parameters {
    BOCeRouterLog(@"Route to ObjectURL:%@\nwithParameters:%@",URL,parameters);
    NSString *rewriteURL = [BOCeRouterRewrite rewriteURL:URL];
    URL = [rewriteURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSMutableDictionary *routerParameters = [[self sharedInstance] achieveParametersFromURL:URL];
    if(!routerParameters){
        BOCeRouterErrorLog(@"Route unregistered ObjectURL:%@",URL);
        [[self sharedInstance] unregisterURLBeRouterWithURL:URL];
        return nil;
    }
    [routerParameters enumerateKeysAndObjectsUsingBlock:^(id key, NSString *obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            routerParameters[key] = [NSString stringWithFormat:@"%@",obj];
        }
    }];
    NSDictionary *coreDic = routerParameters[BOCeRouterCoreKey];
    BOCeObjectRouterHandler handler = coreDic[BOCeRouterCoreBlockKey];
    BOCeRouterType type = [coreDic[BOCeRouterCoreTypeKey] integerValue];
    if (type != BOCeRouterTypeObject) {
        [self routeTypeCheckLogWithCorrectType:type url:URL];
        return nil;
    }
    if (handler) {
        if (parameters) {
            [routerParameters addEntriesFromDictionary:parameters];
        }
        [routerParameters removeObjectForKey:BOCeRouterCoreKey];
        return handler(routerParameters);
    }
    return nil;
}

+ (void)routeCallbackURL:(NSString *)URL targetCallback:(BOCeRouterCallback)targetCallback {
    [self routeCallbackURL:URL withParameters:@{} targetCallback:targetCallback];
}

+ (void)routeCallbackURL:(NSString *)URL withParameters:(NSDictionary<NSString *, id> *)parameters targetCallback:(BOCeRouterCallback)targetCallback {
    BOCeRouterLog(@"Route to URL:%@\nwithParameters:%@",URL,parameters);
    NSString *rewriteURL = [BOCeRouterRewrite rewriteURL:URL];
    URL = [rewriteURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSMutableDictionary *routerParameters = [[self sharedInstance] achieveParametersFromURL:URL];
    if(!routerParameters){
        BOCeRouterErrorLog(@"Route unregistered URL:%@",URL);
        [[self sharedInstance] unregisterURLBeRouterWithURL:URL];
        return;
    }
    
    [routerParameters enumerateKeysAndObjectsUsingBlock:^(id key, NSString *obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            routerParameters[key] = [NSString stringWithFormat:@"%@",obj];
        }
    }];
    
    if (routerParameters) {
        NSDictionary *coreDic = routerParameters[BOCeRouterCoreKey];
        BOCeCallbackRouterHandler handler = coreDic[BOCeRouterCoreBlockKey];
        BOCeRouterType type = [coreDic[BOCeRouterCoreTypeKey] integerValue];
        if (type != BOCeRouterTypeCallback) {
            [self routeTypeCheckLogWithCorrectType:type url:URL];
            return;
        }
        if (parameters) {
            [routerParameters addEntriesFromDictionary:parameters];
        }
        
        if (handler) {
            [routerParameters removeObjectForKey:BOCeRouterCoreKey];
            handler(routerParameters,^(id callbackObjc){
                if (targetCallback) {
                    targetCallback(callbackObjc);
                }
            });
        }
    }
}


+ (void)routeUnregisterURLHandler:(BOCeRouterUnregisterURLHandler)handler {
    [[self sharedInstance] setRouterUnregisterURLHandler:handler];
}

+ (void)unregisterRouteURL:(NSString *)URL {
    [[self sharedInstance] removeRouteURL:URL];
    BOCeRouterLog(@"Unregister URL:%@\nroutes:%@",URL,[[self sharedInstance] routes]);
}

+ (void)unregisterAllRoutes {
    [[self sharedInstance] removeAllRouteURL];
    BOCeRouterLog(@"Unregister All URL\nroutes:%@",[[self sharedInstance] routes]);
}

+ (void)setLogEnabled:(BOOL)enable {
    [BOCeRouterLogger enableLog:enable];
}

#pragma mark - Private Methods
- (void)addRouteURL:(NSString *)routeUrl handler:(BOCeRouterHandler)handlerBlock {
    NSMutableDictionary *subRoutes = [self addURLPattern:routeUrl];
    if (handlerBlock && subRoutes) {
        NSDictionary *coreDic = @{BOCeRouterCoreBlockKey:[handlerBlock copy],BOCeRouterCoreTypeKey:@(BOCeRouterTypeDefault)};
        subRoutes[BOCeRouterCoreKey] = coreDic;
    }
}

- (void)addObjectRouteURL:(NSString *)routeUrl handler:(BOCeObjectRouterHandler)handlerBlock {
    NSMutableDictionary *subRoutes = [self addURLPattern:routeUrl];
    if (handlerBlock && subRoutes) {
        NSDictionary *coreDic = @{BOCeRouterCoreBlockKey:[handlerBlock copy],BOCeRouterCoreTypeKey:@(BOCeRouterTypeObject)};
        subRoutes[BOCeRouterCoreKey] = coreDic;
    }
}

- (void)addCallbackRouteURL:(NSString *)routeUrl handler:(BOCeCallbackRouterHandler)handlerBlock {
    NSMutableDictionary *subRoutes = [self addURLPattern:routeUrl];
    if (handlerBlock && subRoutes) {
        NSDictionary *coreDic = @{BOCeRouterCoreBlockKey:[handlerBlock copy],BOCeRouterCoreTypeKey:@(BOCeRouterTypeCallback)};
        subRoutes[BOCeRouterCoreKey] = coreDic;
    }
}

- (NSMutableDictionary *)addURLPattern:(NSString *)URLPattern {
    NSArray *pathComponents = [self pathComponentsFromURL:URLPattern];
    
    NSMutableDictionary* subRoutes = self.routes;
    
    for (NSString* pathComponent in pathComponents) {
        if (![subRoutes objectForKey:pathComponent]) {
            subRoutes[pathComponent] = [[NSMutableDictionary alloc] init];
        }
        subRoutes = subRoutes[pathComponent];
    }
    return subRoutes;
}

- (void)unregisterURLBeRouterWithURL:(NSString *)URL {
    if (self.routerUnregisterURLHandler) {
        self.routerUnregisterURLHandler(URL);
    }
}

- (void)removeRouteURL:(NSString *)routeUrl{
    if (self.routes.count <= 0) {
        return;
    }
    NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:[self pathComponentsFromURL:routeUrl]];
    BOOL firstPoll = YES;
    
    while(pathComponents.count > 0){
        NSString *componentKey = [pathComponents componentsJoinedByString:@"."];
        NSMutableDictionary *route = [self.routes valueForKeyPath:componentKey];
        
        if (route.count > 1 && firstPoll) {
            [route removeObjectForKey:BOCeRouterCoreKey];
            break;
        }
        if (route.count <= 1 && firstPoll){
            NSString *lastComponent = [pathComponents lastObject];
            [pathComponents removeLastObject];
            NSString *parentComponent = [pathComponents componentsJoinedByString:@"."];
            route = [self.routes valueForKeyPath:parentComponent];
            [route removeObjectForKey:lastComponent];
            firstPoll = NO;
            continue;
        }
        if (route.count > 0 && !firstPoll){
            break;
        }
    }
}

- (void)removeAllRouteURL {
    [self.routes removeAllObjects];
}

- (NSArray*)pathComponentsFromURL:(NSString*)URL {
    
    NSMutableArray *pathComponents = [NSMutableArray array];
    if ([URL rangeOfString:@"://"].location != NSNotFound) {
        NSArray *pathSegments = [URL componentsSeparatedByString:@"://"];
        [pathComponents addObject:pathSegments[0]];
        for (NSInteger idx = 1; idx < pathSegments.count; idx ++) {
            if (idx == 1) {
                URL = [pathSegments objectAtIndex:idx];
            }else{
                URL = [NSString stringWithFormat:@"%@://%@",URL,[pathSegments objectAtIndex:idx]];
            }
        }
    }
    
    if ([URL hasPrefix:@":"]) {
        if ([URL rangeOfString:@"/"].location != NSNotFound) {
            NSArray *pathSegments = [URL componentsSeparatedByString:@"/"];
            [pathComponents addObject:pathSegments[0]];
        }else{
            [pathComponents addObject:URL];
        }
    }else{
        for (NSString *pathComponent in [[NSURL URLWithString:URL] pathComponents]) {
            if ([pathComponent isEqualToString:@"/"]) continue;
            if ([[pathComponent substringToIndex:1] isEqualToString:@"?"]) break;
            [pathComponents addObject:pathComponent];
        }
    }
    return [pathComponents copy];
}

- (NSMutableDictionary *)achieveParametersFromURL:(NSString *)url{
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    parameters[BOCeRouterParameterURLKey] = [url stringByRemovingPercentEncoding];
    
    NSMutableDictionary* subRoutes = self.routes;
    NSArray* pathComponents = [self pathComponentsFromURL:url];
    
    NSInteger pathComponentsSurplus = [pathComponents count];
    BOOL wildcardMatched = NO;
    
    for (NSString* pathComponent in pathComponents) {
        NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch;
        NSArray *subRoutesKeys =[subRoutes.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj2 compare:obj1 options:comparisonOptions];
        }];
        
        for (NSString* key in subRoutesKeys) {
            
            if([pathComponent isEqualToString:key]){
                pathComponentsSurplus --;
                subRoutes = subRoutes[key];
                break;
            }else if([key hasPrefix:@":"] && pathComponentsSurplus == 1){
                subRoutes = subRoutes[key];
                NSString *newKey = [key substringFromIndex:1];
                NSString *newPathComponent = pathComponent;
                
                NSCharacterSet *specialCharacterSet = [NSCharacterSet characterSetWithCharactersInString:BOCeSpecialCharacters];
                NSRange range = [key rangeOfCharacterFromSet:specialCharacterSet];
                
                if (range.location != NSNotFound) {
                    newKey = [newKey substringToIndex:range.location - 1];
                    NSString *suffixToStrip = [key substringFromIndex:range.location];
                    newPathComponent = [newPathComponent stringByReplacingOccurrencesOfString:suffixToStrip withString:@""];
                }
                parameters[newKey] = newPathComponent;
                break;
            }else if([key isEqualToString:BOCeRouterWildcard] && !wildcardMatched){
                subRoutes = subRoutes[key];
                wildcardMatched = YES;
                break;
            }
        }
    }
    
    if (!subRoutes[BOCeRouterCoreKey]) {
        return nil;
    }
    
    NSArray<NSURLQueryItem *> *queryItems = [[NSURLComponents alloc] initWithURL:[[NSURL alloc] initWithString:url] resolvingAgainstBaseURL:false].queryItems;
    
    for (NSURLQueryItem *item in queryItems) {
        parameters[item.name] = item.value;
    }
    
    parameters[BOCeRouterCoreKey] = [subRoutes[BOCeRouterCoreKey] copy];
    return parameters;
}

+ (void)routeTypeCheckLogWithCorrectType:(BOCeRouterType)correctType url:(NSString *)URL{
    if (correctType == BOCeRouterTypeDefault) {
        BOCeRouterErrorLog(@"You must use [routeURL:] or [routeURL: withParameters:] to Route URL:%@",URL);
        NSAssert(NO, @"Method using errors, please see the console log for details.");
    }else if (correctType == BOCeRouterTypeObject) {
        BOCeRouterErrorLog(@"You must use [routeObjectURL:] or [routeObjectURL: withParameters:] to Route URL:%@",URL);
        NSAssert(NO, @"Method using errors, please see the console log for details.");
    }else if (correctType == BOCeRouterTypeCallback) {
        BOCeRouterErrorLog(@"You must use [routeCallbackURL: targetCallback:] or [routeCallbackURL: withParameters: targetCallback:] to Route URL:%@",URL);
        NSAssert(NO, @"Method using errors, please see the console log for details.");
    }
}

#pragma mark - getter/setter
- (NSMutableDictionary *)routes {
    if (!_routes) {
        _routes = [[NSMutableDictionary alloc] init];
    }
    return _routes;
}



@end
