//
//  IGSwitchWithLabelController.h
//  IGGeo
//
//  Created by Isidoro Ghezzi on 20/06/15.
//  Copyright (c) 2015 Isidoro Ghezzi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IGSwitchWithLabelController : UIViewController
@property (weak, nonatomic) IBOutlet UISwitch *fSwitch;
- (instancetype) initWithLabel: (NSString *) theLabel;
@end
