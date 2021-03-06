//
//  IGNodeTableViewCell.m
//  IGGeo
//
//  Created by Isidoro Ghezzi on 14/06/15.
//  Copyright (c) 2015 Isidoro Ghezzi. All rights reserved.
//

#import "IGNodeTableViewCell.h"
#import "IGLabelTextFieldViewController.h"
#import "IGSwitchWithLabelController.h"

@interface IGNodeTableViewCell()
@property (weak, nonatomic) IBOutlet UIView *fSwitchWithLabelSuper;
@end

@implementation IGNodeTableViewCell

- (void)awakeFromNib {
    // Initialization code
	[super awakeFromNib];
    self->_fLabelInputControllers = [NSMutableDictionary dictionaryWithCapacity:3];
    NSDictionary * aDictionary = @{@"x": self.fSuperX, @"y": self.fSuperY, @"r": self.fSuperR};
    for (NSString * aKey in aDictionary.allKeys){
        UIView * aView = aDictionary [aKey];
        IGLabelTextFieldViewController * aController = [[IGLabelTextFieldViewController alloc] init];
        [aView addSubview:aController.view];
        aController.fLabel.text = aKey;
        self->_fLabelInputControllers [aKey] = aController;
    }
    IGSwitchWithLabelController * aSwitchWithLabel = [[IGSwitchWithLabelController alloc] initWithLabel:@"Selected"];
    self->_fSwitchWithLabelController = aSwitchWithLabel;
    [self.fSwitchWithLabelSuper addSubview:aSwitchWithLabel.view];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
