//
//  IGNodeTableViewCell.h
//  IGGeo
//
//  Created by Isidoro Ghezzi on 14/06/15.
//  Copyright (c) 2015 Isidoro Ghezzi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IGNodeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fHeader;
@property (weak, nonatomic) IBOutlet UIButton *fButtonDelete;
@property (weak, nonatomic) IBOutlet UIView *fSuperX;
@property (weak, nonatomic) IBOutlet UIView *fSuperY;
@property (weak, nonatomic) IBOutlet UIView *fSuperR;
@property (readonly, strong, nonatomic) NSMutableDictionary *fLabelInputControllers;
@property (weak, nonatomic) IBOutlet UISwitch *fSwitchSelector;
@end
