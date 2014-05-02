//
//  BabyDateBirthViewController.m
//  ParentsAcademy
//
//  Created by Alex on 5/2/14.
//  Copyright (c) 2014 Alex Shevlyakov. All rights reserved.
//

#import "BabyDateBirthViewController.h"

@interface BabyDateBirthViewController ()

@end

@implementation BabyDateBirthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    NSDate *babyBirthDate = [Settings sharedInstance].babyBirthDate;
    if (babyBirthDate) {
        [self.birthDatePicker setDate: babyBirthDate ];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)birthDateChanged:(id)sender {
    if (NO == [sender isKindOfClass:[UIDatePicker class]]) return;
    
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    [[Settings sharedInstance] setBabyBirthDate: datePicker.date ];
}

@end
