//
//  VideoPageViewController.m
//  ParentsAcademy
//
//  Created by Alex on 5/3/14.
//  Copyright (c) 2014 Alex Shevlyakov. All rights reserved.
//

#import "VideoPageViewController.h"
#import "YouTubeLoader.h"

@interface VideoPageViewController ()

@end

@implementation VideoPageViewController

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
    
//    self.contentScrollView.backgroundColor = [UIColor greenColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self drawLayout];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.videoPlayerViewController.moviePlayer stop];
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

- (void)setVideoItem:(YouTubeItem *)videoItem
{
    _videoItem = videoItem;
}

- (void)drawLayout
{
    if (!self.videoItem) return;
    
    self.navigationItem.title = self.videoItem.title;
    
    self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:self.videoItem.videoId];
    [self.videoPlayerViewController presentInView:self.videoContainerView];
    [self.videoPlayerViewController.moviePlayer play];
    
    // expand scroll view content area
//    CGRect contentRect = CGRectZero;
//    for (UIView *view in self.contentScrollView.subviews) {
//        contentRect = CGRectUnion(contentRect, view.frame);
//    }
//    self.contentScrollView.contentSize = contentRect.size;

}

@end
