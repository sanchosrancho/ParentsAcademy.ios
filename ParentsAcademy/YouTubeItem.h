//
//  YouTubeItem.h
//  ParentsAcademy
//
//  Created by Alex on 5/2/14.
//  Copyright (c) 2014 Alex Shevlyakov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class YouTubePlaylist;

@interface YouTubeItem : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * itemId;
@property (nonatomic, retain) NSString * videoId;
@property (nonatomic, retain) NSString * itemDescription;
@property (nonatomic, retain) NSDate * publishedAt;
@property (nonatomic, retain) NSString * thumbnailDefault;
@property (nonatomic, retain) NSString * thumbnailMedium;
@property (nonatomic, retain) NSString * thumbnailHigh;
@property (nonatomic, retain) NSString * thumbnailCache;
@property (nonatomic, retain) YouTubePlaylist *playlist;

@end
