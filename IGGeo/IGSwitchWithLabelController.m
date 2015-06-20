//
//  IGSwitchWithLabelController.m
//  IGGeo
//
//  Created by Isidoro Ghezzi on 20/06/15.
//  Copyright (c) 2015 Isidoro Ghezzi. All rights reserved.
//

#import "IGSwitchWithLabelController.h"

@interface IGSwitchWithLabelController ()
@property (weak, nonatomic) IBOutlet UILabel *fLabel;
@property (readonly, strong, nonatomic) NSString * fLabelText;
@end

@implementation IGSwitchWithLabelController

- (instancetype) initWithLabel: (NSString *) theLabel{
    self = [self init];
    if (nil != self){
        self->_fLabelText = theLabel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.fLabel.text = self.fLabelText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
