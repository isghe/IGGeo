//
//  NSObject+ExtraProperties.m
//
//  Created by Isidoro Ghezzi on 13/06/15.
//  Copyright (c) 2015 Isidoro Ghezzi. All rights reserved.
//

#import "NSObject+ExtraProperties.h"
#import <objc/runtime.h>

@implementation NSObject (AssociatedDictionary)
@dynamic extraProperties;

- (NSMutableDictionary *)extraProperties{
    static const void *kUniqueDictionaryKey = &kUniqueDictionaryKey;
    // NSLog (@"%s - sizeof (kUniqueDictionaryKey): %@, kUniqueDictionaryKey: %p", __PRETTY_FUNCTION__, @(sizeof (kUniqueDictionaryKey)), kUniqueDictionaryKey);
    NSMutableDictionary * aExtra = objc_getAssociatedObject(self, kUniqueDictionaryKey);
    if (nil == aExtra){
        aExtra = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, kUniqueDictionaryKey, aExtra, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return aExtra;
}
@end
