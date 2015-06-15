//
//  NSObject+AssociatedDictionary.h
//
//  Created by Isidoro Ghezzi on 13/06/15.
//  Copyright (c) 2015 Isidoro Ghezzi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (AssociatedDictionary)
@property (readonly, nonatomic) NSMutableDictionary *extraProperties;
@end
