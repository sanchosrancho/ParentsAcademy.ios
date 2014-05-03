//
//  VideoListViewController.m
//  ParentsAcademy
//
//  Created by Alex on 5/2/14.
//  Copyright (c) 2014 Alex Shevlyakov. All rights reserved.
//

#import "VideoListViewController.h"
#import "YouTubeLoader.h"
#import "DatabaseManager.h"
#import "Settings.h"
#import "VideoPageViewController.h"
#import "VideoListCell.h"

@interface VideoListViewController () <NSFetchedResultsControllerDelegate> {
    NSArray *tableData;
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
}
@end

@implementation VideoListViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        tableData = @[];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        tableData = @[];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [DatabaseManager addListenerForYotubeItemsFetchedResultsController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    Settings *settings = [Settings sharedInstance];
    NSString *playlistId = [settings youtubePlaylistIdForBabyAge: settings.babyAge ];
    [[YouTubeLoader sharedInstance] showOnlyOnePlaylist: playlistId ];
    
    self.navigationItem.title = [settings pageTitleForBabyAge: settings.babyAge ];
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

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[DatabaseManager sharedInstance].youtubeItemsFetchedController.sections objectAtIndex:section];
//    NSInteger num = [[DatabaseManager sharedInstance].youtubeItemsFetchedController.fetchedObjects count];
    NSInteger num = [sectionInfo numberOfObjects];
    NSLog(@"%i items in section %i", num, section);
    
    NSUInteger pl = 0;
    for (YouTubePlaylist *playlist in [DatabaseManager sharedInstance].youtubePlaylistsFetchedController.fetchedObjects) {
        if (!playlist.hidden.boolValue) pl++;
    }
    
    NSLog(@"Visible playlists %i", pl);
    return [sectionInfo numberOfObjects];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath 
{
    NSString *cellID = @"VideoCollectionCell";
    VideoListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    for (UIView *subview in cell.subviews) {
        [subview removeFromSuperview];
    }
    
    YouTubeItem *youtubeVideo = [[DatabaseManager sharedInstance].youtubeItemsFetchedController objectAtIndexPath:indexPath];
    
    cell.title = youtubeVideo.title;

    if (youtubeVideo.thumbnailCache.length) {
        cell.thumbnail = [UIImage imageWithContentsOfFile: [YouTubeLoader fullPathForFile:youtubeVideo.thumbnailCache] ];
    } else {
        [YouTubeLoader downloadThumbnail:youtubeVideo.thumbnailMedium andSaveForItem:youtubeVideo.objectID];
        
        NSString *thumbnailUrl = youtubeVideo.thumbnailMedium;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *img = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnailUrl]];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.thumbnail = [UIImage imageWithData:img];
            });
        });
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    YouTubeItem *youtubeVideo = [[DatabaseManager sharedInstance].youtubeItemsFetchedController objectAtIndexPath:indexPath];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    VideoPageViewController *videoPage = [storyboard instantiateViewControllerWithIdentifier:@"VideoPageViewController"];
    videoPage.videoItem = youtubeVideo;
    
    [self.navigationController pushViewController:videoPage animated:YES];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.collectionView performBatchUpdates:nil completion:nil];
}


#pragma mark - NSFetchedResultsController delegate methods

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    NSLog(@"didChangeObject");
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"controllerDidChangeContent");
    [self.collectionView reloadData];
}


@end
