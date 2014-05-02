//
//  DatabaseManager.h
//  ParentsAcademy
//
//  Created by Alex on 5/2/14.
//  Copyright (c) 2014 Alex Shevlyakov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "YouTubePlaylist.h"
#import "YouTubeItem.h"

@interface DatabaseManager : NSObject <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong, readonly) NSFetchedResultsController *youtubeItemsFetchedController;
@property (nonatomic, strong, readonly) NSFetchedResultsController *youtubePlaylistsFetchedController;

@property (nonatomic, strong, readonly) NSArray *listenersForYoutubeItemsFetchedController;
@property (nonatomic, strong, readonly) NSArray *listenersForYoutubePlaylistFetchedController;


+ (instancetype)sharedInstance;
- (void)saveContext;
- (NSManagedObjectContext *)managedObjectContext;
- (NSFetchedResultsController *)youtubeItemsFetchedController;

- (YouTubeItem *)youtubeFindItemWithId:(NSString *)itemId;
- (BOOL)isYoutubeItemExist:(NSString *)itemId;

- (YouTubePlaylist *)youtubeFindPlaylistWithId:(NSString *)playlistId;
- (BOOL)isYoutubePlaylistExist:(NSString *)playlistId;

+ (void)addListenerForYotubeItemsFetchedResultsController:(id<NSFetchedResultsControllerDelegate>)listener;
+ (void)addListenerForYotubePlaylistFetchedResultsController:(id<NSFetchedResultsControllerDelegate>)listener;
+ (void)removeListener:(id<NSFetchedResultsControllerDelegate>)listener;


@end
