//
//  YouTubeLoader.h
//  ParentsAcademy
//
//  Created by Alex on 5/2/14.
//  Copyright (c) 2014 Alex Shevlyakov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GTLYouTube.h>
#import "DatabaseManager.h"

@interface YouTubeLoader : NSObject

@property (nonatomic, strong, readonly) NSString *APIKey;

+ (instancetype)sharedInstance;
- (void)loadPlaylistsForChannel:(NSString *)channelId;

+ (void)downloadThumbnail:(NSString *)imageURL andSaveForItem:(NSManagedObjectID *)objectId;
+ (NSString *)fullPathForFile:(NSString *)filename;

@end
