//
//  DatabaseManager.m
//  ParentsAcademy
//
//  Created by Alex on 5/2/14.
//  Copyright (c) 2014 Alex Shevlyakov. All rights reserved.
//

#import "DatabaseManager.h"

@interface DatabaseManager()

@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readwrite) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong, readwrite) NSFetchedResultsController *youtubeItemsFetchedController;
@property (nonatomic, strong, readwrite) NSFetchedResultsController *youtubePlaylistsFetchedController;

@property (nonatomic, strong, readwrite) NSArray *listenersForYoutubeItemsFetchedController;
@property (nonatomic, strong, readwrite) NSArray *listenersForYoutubePlaylistFetchedController;

@end

@implementation DatabaseManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (NSFetchedResultsController *)youtubeItemsFetchedController
{
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        
        NSManagedObjectContext *context = self.managedObjectContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"YouTubeItem"];

        
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"playlist.hidden = NO"];        
//        [fetchRequest setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"hidden", nil]];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        self.youtubeItemsFetchedController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
            managedObjectContext:context 
            sectionNameKeyPath:nil 
            cacheName:nil];
        _youtubeItemsFetchedController.delegate = self;
        
        NSError *error;
        BOOL success = [_youtubeItemsFetchedController performFetch:&error];
        if (!success) {
            NSLog(@"Error! Fetching youtube items list.");
        }
    });
    return _youtubeItemsFetchedController;
}


- (NSFetchedResultsController *)youtubePlaylistsFetchedController
{
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        
        NSManagedObjectContext *context = self.managedObjectContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"YouTubePlaylist"];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        self.youtubePlaylistsFetchedController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
            managedObjectContext:context 
            sectionNameKeyPath:nil 
            cacheName:nil];
        _youtubePlaylistsFetchedController.delegate = self;
        
        NSError *error;
        BOOL success = [_youtubePlaylistsFetchedController performFetch:&error];
        if (!success) {
            NSLog(@"Error! Fetching youtube playlists.");
        }
    });
    return _youtubePlaylistsFetchedController;
}


- (YouTubeItem *)youtubeFindItemWithId:(NSString *)itemId
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"YouTubeItem"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemId == %@", itemId];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (array == nil || array.count == 0) return nil;
    return array[0];
}

- (BOOL)isYoutubeItemExist:(NSString *)itemId
{
    return (nil != [self youtubeFindItemWithId:itemId]);
}

- (YouTubePlaylist *)youtubeFindPlaylistWithId:(NSString *)playlistId
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"YouTubePlaylist"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"playlistId == %@", playlistId];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (array == nil || array.count == 0) return nil;
    return array[0];
}

- (BOOL)isYoutubePlaylistExist:(NSString *)playlistId
{
    return (nil != [self youtubeFindPlaylistWithId:playlistId]);
}



- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}


#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"KWModel.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - Fetched results controller delegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    NSArray *array = [[self arrayForFetchedResultsController:controller] copy];
    for (NSObject<NSFetchedResultsControllerDelegate> *delegate in array) {
        if ([delegate respondsToSelector:@selector(controllerWillChangeContent:)]) {
            [delegate controllerWillChangeContent:controller];
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    NSArray *array = [[self arrayForFetchedResultsController:controller] copy];
    for (NSObject<NSFetchedResultsControllerDelegate> *delegate in array) {
        if ([delegate respondsToSelector:@selector(controller:didChangeSection:atIndex:forChangeType:)]) {
            [delegate controller:controller didChangeSection:sectionInfo atIndex:sectionIndex forChangeType:type];
        }
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    NSArray *array = [[self arrayForFetchedResultsController:controller] copy];
    for (NSObject<NSFetchedResultsControllerDelegate> *delegate in array) {
        if ([delegate respondsToSelector:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
			[delegate controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSArray *array = [[self arrayForFetchedResultsController:controller] copy];
    for (NSObject<NSFetchedResultsControllerDelegate> *delegate in array) {
        if ([delegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
            [delegate controllerDidChangeContent:controller];
        }
    }
}

- (NSArray*)arrayForFetchedResultsController:(NSFetchedResultsController *)controller
{
         if (controller == self.youtubeItemsFetchedController)     return self.listenersForYoutubeItemsFetchedController;
    else if (controller == self.youtubePlaylistsFetchedController) return self.listenersForYoutubePlaylistFetchedController;
    else return nil;
}


#pragma mark - Getters and setters

- (NSArray *)listenersForYoutubeItemsFetchedController
{
    if (!_listenersForYoutubeItemsFetchedController) {
        self.listenersForYoutubeItemsFetchedController = [NSMutableArray array];
    }
    return _listenersForYoutubeItemsFetchedController;
}

- (NSArray *)listenersForYoutubePlaylistFetchedController
{
    if (!_listenersForYoutubePlaylistFetchedController) {
        self.listenersForYoutubePlaylistFetchedController = [NSMutableArray array];
    }
    return _listenersForYoutubePlaylistFetchedController;
}


+ (void)addListenerForYotubeItemsFetchedResultsController:(id<NSFetchedResultsControllerDelegate>)listener
{
    if (![[DatabaseManager sharedInstance].listenersForYoutubeItemsFetchedController containsObject:listener]) {
        NSMutableArray *listeners = [NSMutableArray arrayWithArray:[DatabaseManager sharedInstance].listenersForYoutubeItemsFetchedController];
        [listeners addObject:listener];
        [DatabaseManager sharedInstance].listenersForYoutubeItemsFetchedController = [NSArray arrayWithArray:listeners];
    }
}

+ (void)addListenerForYotubePlaylistFetchedResultsController:(id<NSFetchedResultsControllerDelegate>)listener
{
    if (![[DatabaseManager sharedInstance].listenersForYoutubePlaylistFetchedController containsObject:listener]) {
        NSMutableArray *listeners = [NSMutableArray arrayWithArray:[DatabaseManager sharedInstance].listenersForYoutubePlaylistFetchedController];
        [listeners addObject:listener];
        [DatabaseManager sharedInstance].listenersForYoutubePlaylistFetchedController = [NSArray arrayWithArray:listeners];
    }
}

+ (void)removeListener:(id<NSFetchedResultsControllerDelegate>)listener
{
    if ([[DatabaseManager sharedInstance].listenersForYoutubeItemsFetchedController containsObject:listener]) {
        NSMutableArray *listeners = [NSMutableArray arrayWithArray:[DatabaseManager sharedInstance].listenersForYoutubeItemsFetchedController];
        [listeners removeObject:listener];
        [DatabaseManager sharedInstance].listenersForYoutubeItemsFetchedController = [NSArray arrayWithArray:listeners];
    }
    
    if ([[DatabaseManager sharedInstance].listenersForYoutubePlaylistFetchedController containsObject:listener]) {
        NSMutableArray *listeners = [NSMutableArray arrayWithArray:[DatabaseManager sharedInstance].listenersForYoutubePlaylistFetchedController];
        [listeners removeObject:listener];
        [DatabaseManager sharedInstance].listenersForYoutubePlaylistFetchedController = [NSArray arrayWithArray:listeners];
    }
}

@end
