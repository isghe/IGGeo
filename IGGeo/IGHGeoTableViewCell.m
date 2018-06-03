//
//  IGHGeoTableViewCell.m
//  IGGeo
//
//  Created by Isidoro Ghezzi on 13/06/15.
//  Copyright (c) 2015 Isidoro Ghezzi. All rights reserved.
//

#import "IGHGeoTableViewCell.h"

@implementation IGHGeoTableViewCell

- (void)awakeFromNib {
    // Initialization code
	[super awakeFromNib];
    self.fLabelStatus.text = @"Unknown";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
