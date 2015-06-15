//
//  IGCDCircle.h
//  IGGeo
//
//  Created by Isidoro Ghezzi on 13/06/15.
//  Copyright (c) 2015 Isidoro Ghezzi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class IGCDHGeo, IGCDPoint;

@interface IGCDCircle : NSManagedObject

@property (nonatomic, retain) NSNumber * radius;
@property (nonatomic, retain) IGCDHGeo *circle_pt_geo;
@property (nonatomic, retain) IGCDPoint *circle_pt_point;

@end
