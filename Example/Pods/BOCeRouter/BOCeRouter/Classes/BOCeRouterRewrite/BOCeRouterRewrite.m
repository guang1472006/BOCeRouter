//
//  BOCeRouterRewrite.m
//  ss
//
//  Created by boce on 2019/9/9.
//  Copyright © 2019 boce. All rights reserved.
//

#import "BOCeRouterRewrite.h"
#import "BOCeRouterLogger.h"

NSString *const BOCeRouterRewriteMatchRuleKey = @"matchRule";
NSString *const BOCeRouterRewriteTargetRuleKey = @"targetRule";

NSString *const BOCeRouterRewriteComponentURLKey = @"url";
NSString *const BOCeRouterRewriteComponentSchemeKey = @"scheme";
NSString *const BOCeRouterRewriteComponentHostKey = @"host";
NSString *const BOCeRouterRewriteComponentPortKey = @"port";
NSString *const BOCeRouterRewriteComponentPathKey = @"path";
NSString *const BOCeRouterRewriteComponentQueryKey = @"query";
NSString *const BOCeRouterRewriteComponentFragmentKey = @"fragment";

@interface BOCeRouterRewrite()

@property(nonatomic, strong) NSMutableArray *rewriteRules;

@end

@implementation BOCeRouterRewrite

+ (instancetype)sharedInstance
{
    static BOCeRouterRewrite *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - Public Methods
+ (NSString *)rewriteURL:(NSString *)URL {
    
    if (!URL) return nil;
    if ([[self sharedInstance] rewriteRules].count == 0 ) return URL;
    
    NSString *rewriteCaptureGroupsURL = [self rewriteCaptureGroupsWithOriginalURL:URL];
    NSString *rewrittenURL = [self rewriteComponentsWithOriginalURL:URL targetRule:rewriteCaptureGroupsURL];
    if (![rewrittenURL isEqualToString:URL]) {
        BOCeRouterLog(@"rewriteURL:%@ to:%@",URL,rewrittenURL);
    }
    return rewrittenURL;
}

+ (void)addRewriteMatchRule:(NSString *)matchRule targetRule:(NSString *)targetRule {
    BOCeRouterLog(@"addRewriteMatchRule matchRule:%@ targetRule:%@",matchRule,targetRule);
    
    if (!matchRule || !targetRule) return;
    
    NSArray *rules = [[[self sharedInstance] rewriteRules] copy];
    
    for (int idx = 0; idx < rules.count; idx ++) {
        NSDictionary *ruleDic = [rules objectAtIndex:idx];
        if ([[ruleDic objectForKey:BOCeRouterRewriteMatchRuleKey] isEqualToString:matchRule]) {
            [[[self sharedInstance] rewriteRules] removeObject:ruleDic];
        }
    }
    
    NSDictionary *ruleDic = @{BOCeRouterRewriteMatchRuleKey:matchRule,BOCeRouterRewriteTargetRuleKey:targetRule};
    [[[self sharedInstance] rewriteRules] addObject:ruleDic];
    
}

+ (void)addRewriteRules:(NSArray<NSDictionary *> *)rules {
    if (!rules) return;
    BOCeRouterLog(@"addRewriteRules:%@",rules);
    
    for (int idx = 0; idx < rules.count; idx ++) {
        id ruleObjc = [rules objectAtIndex:idx];
        
        if (![ruleObjc isKindOfClass:[NSDictionary class]]) {
            BOCeRouterErrorLog(@"The data type is not valid,the element must be a dictionary. invalid data:%@",ruleObjc);
            continue;
        }
        NSDictionary *ruleDic = [rules objectAtIndex:idx];
        NSString *matchRule = [ruleDic objectForKey:BOCeRouterRewriteMatchRuleKey];
        NSString *targetRule = [ruleDic objectForKey:BOCeRouterRewriteTargetRuleKey];
        if (!matchRule || !targetRule) {
            BOCeRouterErrorLog(@"The data type is not valid,The dictionary must contain two keys:\"%@\" and \"%@\".invalid data:%@",BOCeRouterRewriteMatchRuleKey,BOCeRouterRewriteTargetRuleKey,ruleDic);
            continue;
        }
        [self addRewriteMatchRule:matchRule targetRule:targetRule];
        
    }
}

+ (void)removeRewriteMatchRule:(NSString *)matchRule {
    BOCeRouterLog(@"removeRewriteMatchRule:%@",matchRule);
    NSArray *rules = [[[self sharedInstance] rewriteRules] copy];
    
    for (int idx = 0; idx < rules.count; idx ++) {
        NSDictionary *ruleDic = [rules objectAtIndex:idx];
        if ([[ruleDic objectForKey:BOCeRouterRewriteMatchRuleKey] isEqualToString:matchRule]) {
            [[[self sharedInstance] rewriteRules] removeObject:ruleDic];
            break;
        }
    }
}

+ (void)removeAllRewriteRules {
    [[[self sharedInstance] rewriteRules] removeAllObjects];
    BOCeRouterLog(@"removeAllRewriteRules,rewriteRules:%@",[[self sharedInstance] rewriteRules]);
}

#pragma mark - Private Methods
+ (NSString *)rewriteCaptureGroupsWithOriginalURL:(NSString *)originalURL {
    
    NSArray *rules = [[self sharedInstance] rewriteRules];
    
    if ([rules isKindOfClass:[NSArray class]] && rules.count > 0) {
        NSString *targetURL = originalURL;
        NSRegularExpression *replaceRx = [NSRegularExpression regularExpressionWithPattern:@"[$]([$|#]?)(\\d+)" options:0 error:NULL];
        
        for (NSDictionary *rule in rules) {
            NSString *matchRule = [rule objectForKey:BOCeRouterRewriteMatchRuleKey];
            if (!([matchRule isKindOfClass:[NSString class]] && matchRule.length > 0)) continue;
            
            NSRange searchRange = NSMakeRange(0, targetURL.length);
            NSRegularExpression *rx = [NSRegularExpression regularExpressionWithPattern:matchRule options:0 error:NULL];
            NSRange range = [rx rangeOfFirstMatchInString:targetURL options:0 range:searchRange];
            
            if (range.length != 0) {
                NSMutableArray *groupValues = [NSMutableArray array];
                NSTextCheckingResult *result = [rx firstMatchInString:targetURL options:0 range:searchRange];
                for (NSInteger idx = 0; idx<rx.numberOfCaptureGroups + 1; idx++) {
                    NSRange groupRange = [result rangeAtIndex:idx];
                    if (groupRange.length != 0) {
                        [groupValues addObject:[targetURL substringWithRange:groupRange]];
                    }
                }
                NSString *targetRule = [rule objectForKey:BOCeRouterRewriteTargetRuleKey];
                NSMutableString *newTargetURL = [NSMutableString stringWithString:targetRule];
                [replaceRx enumerateMatchesInString:targetRule options:0 range:NSMakeRange(0, targetRule.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                    NSRange matchRange = result.range;
                    
                    NSRange secondGroupRange = [result rangeAtIndex:2];
                    NSString *replacedValue = [targetRule substringWithRange:matchRange];
                    NSInteger index = [[targetRule substringWithRange:secondGroupRange] integerValue];
                    if (index >= 0 && index < groupValues.count) {
                        
                        NSString *newValue = [self convertCaptureGroupsWithCheckingResult:result targetRule:targetRule originalValue:groupValues[index]];
                        [newTargetURL replaceOccurrencesOfString:replacedValue withString:newValue options:0 range:NSMakeRange(0, newTargetURL.length)];
                    }
                }];
                return newTargetURL;
            }
        }
    }
    return originalURL;
}

+ (NSString *)rewriteComponentsWithOriginalURL:(NSString *)originalURL targetRule:(NSString *)targetRule {
    
    NSString *encodeURL = [originalURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:encodeURL];
    NSMutableDictionary *componentDic = [[NSMutableDictionary alloc] init];
    [componentDic setValue:originalURL forKey:BOCeRouterRewriteComponentURLKey];
    [componentDic setValue:urlComponents.scheme forKey:BOCeRouterRewriteComponentSchemeKey];
    [componentDic setValue:urlComponents.host forKey:BOCeRouterRewriteComponentHostKey];
    [componentDic setValue:urlComponents.port forKey:BOCeRouterRewriteComponentPortKey];
    [componentDic setValue:urlComponents.path forKey:BOCeRouterRewriteComponentPathKey];
    [componentDic setValue:urlComponents.query forKey:BOCeRouterRewriteComponentQueryKey];
    [componentDic setValue:urlComponents.fragment forKey:BOCeRouterRewriteComponentFragmentKey];
    
    NSMutableString *targetURL = [NSMutableString stringWithString:targetRule];
    NSRegularExpression *replaceRx = [NSRegularExpression regularExpressionWithPattern:@"[$]([$|#]?)(\\w+)" options:0 error:NULL];
    
    [replaceRx enumerateMatchesInString:targetRule options:0 range:NSMakeRange(0, targetRule.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        NSRange matchRange = result.range;
        NSRange secondGroupRange = [result rangeAtIndex:2];
        NSString *replaceValue = [targetRule substringWithRange:matchRange];
        NSString *componentKey = [targetRule substringWithRange:secondGroupRange];
        NSString *componentValue = [componentDic valueForKey:componentKey];
        if (!componentValue) {
            componentValue = @"";
        }
        
        NSString *newValue = [self convertCaptureGroupsWithCheckingResult:result targetRule:targetRule originalValue:componentValue];
        [targetURL replaceOccurrencesOfString:replaceValue withString:newValue options:0 range:NSMakeRange(0, targetURL.length)];
    }];
    
    return targetURL;
}


+ (NSString *)convertCaptureGroupsWithCheckingResult:(NSTextCheckingResult *)checkingResult targetRule:(NSString *)targetRule originalValue:(NSString *)originalValue {
    
    NSString *convertValue = originalValue;
    
    NSRange convertKeyRange = [checkingResult rangeAtIndex:1];
    NSString *convertKey = [targetRule substringWithRange:convertKeyRange];
    if ([convertKey isEqualToString:@"$"]) {
        //URL Encode
        convertValue = [originalValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }else if([convertKey isEqualToString:@"#"]){
        //URL Decode
        convertValue = [originalValue stringByRemovingPercentEncoding];
    }
    
    return convertValue;
}


#pragma mark - getter/setter
- (NSMutableArray *)rewriteRules {
    if (!_rewriteRules) {
        _rewriteRules = [[NSMutableArray alloc] init];
    }
    return _rewriteRules;
}


@end
