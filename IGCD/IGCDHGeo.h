//
//  IGCDHGeo.h
//  IGGeo
//
//  Created by Isidoro Ghezzi on 13/06/15.
//  Copyright (c) 2015 Isidoro Ghezzi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSManagedObject, IGCDAGeoStatus;

@interface IGCDHGeo : NSManagedObject

@property (nonatomic, retain) NSDate * dateTimeInsert;
@property (nonatomic, retain) IGCDAGeoStatus *geo_pt_status;

@end
