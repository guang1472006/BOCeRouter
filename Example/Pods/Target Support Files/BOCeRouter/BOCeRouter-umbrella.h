#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "BOCeRouter.h"
#import "BOCeRouterLogger.h"
#import "BOCeRouterNavigation.h"
#import "BOCeRouterRewrite.h"

FOUNDATION_EXPORT double BOCeRouterVersionNumber;
FOUNDATION_EXPORT const unsigned char BOCeRouterVersionString[];

