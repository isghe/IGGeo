//
//  IGCDConnection.h
//  IGGeo
//
//  Created by Isidoro Ghezzi on 13/06/15.
//  Copyright (c) 2015 Isidoro Ghezzi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class IGCDCircle;

@interface IGCDConnection : NSManagedObject

@property (nonatomic, retain) IGCDCircle *connection_pt_circle1;
@property (nonatomic, retain) IGCDCircle *connection_pt_circle2;

@end
