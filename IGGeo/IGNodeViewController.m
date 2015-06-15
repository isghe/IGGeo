//
//  IGNodeViewController.m
//  IGGeo
//
//  Created by Isidoro Ghezzi on 14/06/15.
//  Copyright (c) 2015 Isidoro Ghezzi. All rights reserved.
//

#import "IGNodeViewController.h"
#import "IGNodeTableViewCell.h"
#import "ViewController.h"
#import "IGCDPoint.h"
#import "IGCDCircle.h"
#import "NSObject+ExtraProperties.h"
#import "IGLabelTextFieldViewController.h"

@interface IGNodeViewController (){
    CGRect fBeganFrame;
    NSUInteger fNumberOfRows;
}

@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *PanGestureRecognizer;
@property (weak, nonatomic) IBOutlet UITableView *fNodeTableViewController;

@end

@implementation IGNodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSParameterAssert(nil != self.fRootViewController);
    NSParameterAssert(nil != self.fInfo);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)actionClose:(id)sender {
    self.view.hidden = YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionPanGesture:(UIPanGestureRecognizer *)sender {
    const CGPoint aPoint = [sender translationInView:self.view];
    // NSLog (@"%s - aPoint: %@",__PRETTY_FUNCTION__,  NSStringFromCGPoint(aPoint));
    if (UIGestureRecognizerStateBegan == sender.state ){
        self->fBeganFrame = self.view.frame;
    }
    self.view.frame = CGRectMake(self->fBeganFrame.origin.x + aPoint.x, self->fBeganFrame.origin.y + aPoint.y, self->fBeganFrame.size.width, self->fBeganFrame.size.height);
    if (UIGestureRecognizerStateEnded == sender.state){
        self->fBeganFrame = self.view.frame;
    }
}

- (IBAction)actionAdd:(id)sender {
    [self.fRootViewController geoInsertCircle:self.fInfo [@"geo"] withOrigin:CGPointZero andRadious:0];
    [self.fRootViewController geoSave];
    [self.fNodeTableViewController reloadData];
}
#pragma mark - UITableViewDelegate

- (void)actionDeleteCircle:(id)sender{
    UIButton * aButton = sender;
    NSDictionary * aInfo = aButton.superview.extraProperties [@"ig_geo"];
    NSParameterAssert([aInfo [@"circle"] isKindOfClass:[IGCDCircle class]]);
    IGCDCircle * aCircle = aInfo [@"circle"];
    [self.fRootViewController geoDeleteCircle:aCircle];
    [self.fRootViewController geoSave];
    [self.fNodeTableViewController reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self->fNumberOfRows = [self.fRootViewController geoCircles:self.fInfo [@"geo"]].count;
    return self->fNumberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifier = @"Cell4";
    IGNodeTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (nil == cell){
        [tableView registerNib:[UINib nibWithNibName:@"IGNodeTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier];
        cell = [[IGNodeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        NSLog (@"%s - registerNib", __PRETTY_FUNCTION__);
        cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    }
    NSParameterAssert(nil != cell);
    NSParameterAssert(nil != cell.fHeader);
    return cell;
}

- (void) actionTextFieldChanged: (UITextField *) sender{
    NSDictionary * aDictionary = sender.extraProperties [@"ig_geo"];
    IGCDCircle * aCircle = aDictionary [@"circle"];
    NSNumber * aNumber = aDictionary [@"number"];
    NSString * aKey = aDictionary [@"key"];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber * aInputNumber = [formatter numberFromString:sender.text];
    NSLog(@"%s - %@; text: %@; aInputNumber: %@", __PRETTY_FUNCTION__, aNumber, sender.text, aInputNumber.description);
    BOOL aFlagPleaseSave = FALSE;
    if (nil == aInputNumber){
        sender.text = aNumber.description;
    }
    else{
        if ([aKey isEqual:@"x"]){
            aCircle.circle_pt_point.x = aInputNumber;
            aFlagPleaseSave = TRUE;
        }
        else{
            if ([aKey isEqual:@"y"]){
                aCircle.circle_pt_point.y = aInputNumber;
                aFlagPleaseSave = TRUE;
            }
            else{
                NSParameterAssert([aKey isEqual:@"r"]);
                if (aInputNumber >= 0){
                    aCircle.radius = aInputNumber;
                    aFlagPleaseSave = TRUE;
                }
            }
        }
    }
    NSLog (@"%s - %@ %@; aFlagPleaseSave: %@", __PRETTY_FUNCTION__, aCircle.circle_pt_point.description, aCircle.description, @(aFlagPleaseSave));
    if (aFlagPleaseSave){
        [self.fRootViewController geoSave];
        [self.fGeoViewController updateUI];
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(IGNodeTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    const NSUInteger aNumberoOfRows = self->fNumberOfRows; // [self.fRootViewController geoCircles:self.fInfo [@"geo"]].count;

    IGCDCircle * aCircle = [self.fRootViewController geoCircles:self.fInfo [@"geo"]][indexPath.row];
    const NSUInteger aNumberOfConnections = [self.fRootViewController geoConnections: aCircle].count;
    // cell.fHeader.text = [NSString stringWithFormat: @"%@/%@ - x:%@; y:%@; radius:%@; connections: %@",  @(indexPath.row +1), @(aNumberoOfRows), aCircle.circle_pt_point.x, aCircle.circle_pt_point.y, aCircle.radius, @(aNumberOfConnections)];
    NSParameterAssert(nil != cell.fHeader);
    cell.fHeader.text = [NSString stringWithFormat: @"%@/%@ - connections: %@",  @(indexPath.row +1), @(aNumberoOfRows), @(aNumberOfConnections)];
    [cell.fHeader setNeedsDisplay];
    cell.contentView.extraProperties [@"ig_geo"] = @{@"circle": aCircle, @"index_path": indexPath};

    NSDictionary * aDictionary = @{@"x": aCircle.circle_pt_point.x, @"y": aCircle.circle_pt_point.y, @"r": aCircle.radius};
    for (NSString * aKey in aDictionary){
        NSNumber * aNumber = aDictionary [aKey];
        IGLabelTextFieldViewController * aController = cell.fLabelInputControllers [aKey];
        aController.fTextField.text = aNumber.description;
        [aController.fTextField addTarget:self action:@selector(actionTextFieldChanged:) forControlEvents: UIControlEventEditingDidEndOnExit];
        aController.fTextField.extraProperties [@"ig_geo"] = @{@"circle": aCircle, @"number": aNumber, @"key": aKey};
    }
    [cell.fButtonDelete addTarget:self action:@selector(actionDeleteCircle:) forControlEvents:UIControlEventTouchUpInside];
   
    // NSLog(@"%s - aString: %@, %p", __PRETTY_FUNCTION__, aString, cell.fHeader);
    // cell.textLabel.text = [NSString stringWithFormat:@"test %@", @(indexPath.row +1)];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog (@"%s - indexPath.row: %@", __PRETTY_FUNCTION__, @(indexPath.row));
    /*
     IGGeoViewController * aGeoViewController = [[IGGeoViewController alloc] init];
     [self presentViewController:aGeoViewController animated:YES completion:^{}];
     */
}
@end
