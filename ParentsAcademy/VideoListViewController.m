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
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"VideoCellIdentifier"];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];

    [self.view addSubview:self.collectionView];
    
    
    [[YouTubeLoader sharedInstance] loadPlaylistsForChannel:@"UCXfLC9ybl3aIUZpuoA_gRDA"];
    [DatabaseManager addListenerForYotubeItemsFetchedResultsController:self];
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
    NSString *cellID = @"VideoCellIdentifier";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    YouTubeItem *youtubeVideo = [[DatabaseManager sharedInstance].youtubeItemsFetchedController objectAtIndexPath:indexPath];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_thumnail_default"]];
    [imageView setFrame:cell.bounds];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [cell addSubview:imageView];

    if (youtubeVideo.thumbnailCache.length) {
        imageView.image = [UIImage imageWithContentsOfFile: [YouTubeLoader fullPathForFile:youtubeVideo.thumbnailCache] ];
    } else {
        [YouTubeLoader downloadThumbnail:youtubeVideo.thumbnailMedium andSaveForItem:youtubeVideo.objectID];
        
        NSString *thumbnailUrl = youtubeVideo.thumbnailMedium;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *img = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnailUrl]];
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = [UIImage imageWithData:img];
            });
        });
    }

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout  *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(192.f, 192.f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 10, 0, 10);  // top, left, bottom, right
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
