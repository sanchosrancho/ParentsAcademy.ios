//
//  YouTubeLoader.m
//  ParentsAcademy
//
//  Created by Alex on 5/2/14.
//  Copyright (c) 2014 Alex Shevlyakov. All rights reserved.
//

#import "YouTubeLoader.h"

@implementation YouTubeLoader

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSString *)APIKey
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"YouTube API Key"];
}

- (void)loadPlaylistsForChannel:(NSString *)channelId
{
    GTLServiceYouTube *service = [[GTLServiceYouTube alloc] init];
    service.APIKey = self.APIKey;

    GTLQueryYouTube *query = [GTLQueryYouTube queryForPlaylistsListWithPart:@"snippet"];
    query.channelId = channelId;
    
    [service executeQuery:query
        completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
            if (error == nil) {
            
                GTLYouTubePlaylistListResponse *playlists = object;
                for (GTLYouTubePlaylist *gtlPlaylist in playlists.items) {
                    
                    YouTubePlaylist *playlist = [[DatabaseManager sharedInstance] youtubeFindPlaylistWithId:gtlPlaylist.identifier];
                    if (!playlist) {
                        playlist = [self savePlaylist:gtlPlaylist];
                    }
                    [self loadPlaylistItems:playlist];
                    
                }
            
            } else {
                NSLog(@"Error: %@", error.description);
            }
            
            
        }
    ];
}

- (void)loadPlaylistItems:(YouTubePlaylist *)playlist
{
    GTLServiceYouTube *service = [[GTLServiceYouTube alloc] init];
    service.APIKey = self.APIKey;
    
    GTLQueryYouTube *query = [GTLQueryYouTube queryForPlaylistItemsListWithPart:@"id,snippet,contentDetails"];
    query.playlistId = playlist.playlistId; // @"PLehkANA0TeYF9D3TJc1JONQYH_pH5P2QI";
    query.maxResults = 50;
    query.type = @"video";
    
    [service executeQuery:query
        completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
            if (error == nil) {
            
                GTLYouTubePlaylistItemListResponse *products = object;
                for (id item in products.items) {
                    GTLYouTubePlaylistItem *result = item;
                    
                    if ([[DatabaseManager sharedInstance] isYoutubeItemExist:result.identifier]) {
                        continue;
                    }
                    
                    [self saveItem:result forPlaylist:playlist];
                }
                
            } else {
                NSLog(@"Error: %@", error.description);
            }
    }];
}

- (YouTubeItem *)saveItem:(GTLYouTubePlaylistItem *)gtlItem forPlaylist:(YouTubePlaylist *)playlist
{
    NSString *entityName = NSStringFromClass([YouTubeItem class]);
    NSEntityDescription *entity = [[[DatabaseManager sharedInstance].managedObjectModel entitiesByName] objectForKey:entityName];
    YouTubeItem *youtubeItem = (YouTubeItem *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:[DatabaseManager sharedInstance].managedObjectContext];

    youtubeItem.itemId  = gtlItem.identifier;
    youtubeItem.videoId = gtlItem.contentDetails.videoId;
    youtubeItem.title   = gtlItem.snippet.title;
    youtubeItem.itemDescription  = gtlItem.snippet.descriptionProperty;
    youtubeItem.thumbnailDefault = [[gtlItem.snippet.thumbnails.JSON objectForKey:@"default"] objectForKey:@"url"];
    youtubeItem.thumbnailMedium  = [[gtlItem.snippet.thumbnails.JSON objectForKey:@"medium"]  objectForKey:@"url"];
    youtubeItem.thumbnailHigh    = [[gtlItem.snippet.thumbnails.JSON objectForKey:@"high"]    objectForKey:@"url"];
    
    youtubeItem.playlist = playlist;
    
    [YouTubeLoader downloadThumbnail:youtubeItem.thumbnailMedium andSaveForItem:youtubeItem.objectID];
    
    [[DatabaseManager sharedInstance] saveContext];
    
    return youtubeItem;
}

- (YouTubePlaylist *)savePlaylist:(GTLYouTubePlaylist *)gtlPlaylist
{
    NSString *entityName = NSStringFromClass([YouTubePlaylist class]);
    NSEntityDescription *entity = [[[DatabaseManager sharedInstance].managedObjectModel entitiesByName] objectForKey:entityName];
    YouTubePlaylist *youtubePlaylist = (YouTubePlaylist *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:[DatabaseManager sharedInstance].managedObjectContext];

    youtubePlaylist.playlistId          = gtlPlaylist.identifier;
    youtubePlaylist.title               = gtlPlaylist.snippet.title;
    youtubePlaylist.playlistDescription = gtlPlaylist.snippet.description;
    youtubePlaylist.hidden = [NSNumber numberWithBool:NO];
    
    [[DatabaseManager sharedInstance] saveContext];
    
    return youtubePlaylist;
}

+ (void)downloadThumbnail:(NSString *)imageURL andSaveForItem:(NSManagedObjectID *)objectId
{
    NSURL *url = [NSURL URLWithString:imageURL];
    if (url == nil) return;
    
//    NSString *filename = [url lastPathComponent];
    NSString *filename = [NSString stringWithFormat:@"thumb_%@", [[NSProcessInfo processInfo] globallyUniqueString]];
    NSString *finalPath = [YouTubeLoader fullPathForFile:filename];

    dispatch_queue_t imageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,  0ul);
    dispatch_async(imageQueue, ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        [data writeToFile:finalPath atomically:YES];
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [data writeToFile:finalPath atomically:YES];
//        });

        dispatch_async(dispatch_get_main_queue(), ^{
            DatabaseManager *db = [DatabaseManager sharedInstance];
            NSError *error = nil;
            YouTubeItem *item = (YouTubeItem *)[db.managedObjectContext existingObjectWithID:objectId error:&error];
            if (item) {
                item.thumbnailCache = filename;
                [db saveContext];
            }
        });
        
    });
}

+ (NSString *)fullPathForFile:(NSString *)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:filename];
}


@end
