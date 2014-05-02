//
//  YouTubePlaylist.h
//  ParentsAcademy
//
//  Created by Alex on 5/2/14.
//  Copyright (c) 2014 Alex Shevlyakov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface YouTubePlaylist : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * playlistId;
@property (nonatomic, retain) NSString * playlistDescription;
@property (nonatomic, retain) NSNumber * hidden;
@property (nonatomic, retain) NSSet *items;
@end

@interface YouTubePlaylist (CoreDataGeneratedAccessors)

- (void)addItemsObject:(NSManagedObject *)value;
- (void)removeItemsObject:(NSManagedObject *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
