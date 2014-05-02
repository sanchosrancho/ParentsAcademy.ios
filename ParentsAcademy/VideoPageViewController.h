//
//  VideoPageViewController.h
//  ParentsAcademy
//
//  Created by Alex on 5/3/14.
//  Copyright (c) 2014 Alex Shevlyakov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseManager.h"

@interface VideoPageViewController : UIViewController

@property (nonatomic, strong) YouTubeItem *videoItem;

@property (weak, nonatomic) IBOutlet UIView *videoContainerView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;

@end
