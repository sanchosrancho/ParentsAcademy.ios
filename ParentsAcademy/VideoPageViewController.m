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
    
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_thumnail_default"]];
//    [imageView setFrame:self.videoContainerView.bounds];
//    [imageView setContentMode:UIViewContentModeScaleAspectFit];
//    [self.videoContainerView addSubview:imageView];
//    
//    if (self.videoItem.thumbnailCache.length) {
//        imageView.image = [UIImage imageWithContentsOfFile: [YouTubeLoader fullPathForFile:self.videoItem.thumbnailCache] ];
//    } else {
//        [YouTubeLoader downloadThumbnail:self.videoItem.thumbnailMedium andSaveForItem:self.videoItem.objectID];
//        
//        NSString *thumbnailUrl = self.videoItem.thumbnailMedium;
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//            NSData *img = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnailUrl]];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                imageView.image = [UIImage imageWithData:img];
//            });
//        });
//    }
    
    
    
}

@end
