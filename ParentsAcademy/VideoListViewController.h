//
//  VideoListViewController.h
//  ParentsAcademy
//
//  Created by Alex on 5/2/14.
//  Copyright (c) 2014 Alex Shevlyakov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCDYouTubeVideoPlayerViewController.h>

@interface VideoListViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) XCDYouTubeVideoPlayerViewController *videoPlayerViewController;

@end
