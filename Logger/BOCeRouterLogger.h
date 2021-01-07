//
//  BOCeRouterLogger.h
//  ss
//
//  Created by boce on 2019/9/9.
//  Copyright © 2019 boce. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BOCeRouterLogLevel(lvl,fmt,...)\
[BOCeRouterLogger log : YES                                      \
level : lvl                                                  \
format : (fmt), ## __VA_ARGS__]

#define BOCeRouterLog(fmt,...)\
BOCeRouterLogLevel(BOCeRouterLoggerLevelInfo,(fmt), ## __VA_ARGS__)

#define BOCeRouterWarningLog(fmt,...)\
BOCeRouterLogLevel(BOCeRouterLoggerLevelWarning,(fmt), ## __VA_ARGS__)

#define BOCeRouterErrorLog(fmt,...)\
BOCeRouterLogLevel(BOCeRouterLoggerLevelError,(fmt), ## __VA_ARGS__)


typedef NS_ENUM(NSUInteger,BOCeRouterLoggerLevel){
    BOCeRouterLoggerLevelInfo = 1,
    BOCeRouterLoggerLevelWarning ,
    BOCeRouterLoggerLevelError ,
};


NS_ASSUME_NONNULL_BEGIN

@interface BOCeRouterLogger : NSObject

//@property(class , readonly, strong) BOCeRouterLogger *sharedInstance;

+ (BOOL)isLoggerEnabled;

+ (void)enableLog:(BOOL)enableLog;

+ (void)log:(BOOL)asynchronous
      level:(NSInteger)level
     format:(NSString *)format, ...;


@end

NS_ASSUME_NONNULL_END
