//
//  BabyDateBirthViewController.h
//  ParentsAcademy
//
//  Created by Alex on 5/2/14.
//  Copyright (c) 2014 Alex Shevlyakov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Settings.h"

@interface BabyDateBirthViewController : UIViewController 

@property (weak, nonatomic) IBOutlet UIDatePicker *birthDatePicker;

- (IBAction)birthDateChanged:(id)sender;

@end
