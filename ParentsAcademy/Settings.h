//
//  Settings.h
//  ParentsAcademy
//
//  Created by Alex on 5/2/14.
//  Copyright (c) 2014 Alex Shevlyakov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    BabyAgeNotYetBorn,
    BabyAgeUnder1Year,
    BabyAgeUnder2Years,
    BabyAgeUnder3Years
} BabyAge;
#define BabyAgeString(enum) [@[@"BabyAgeNotYetBorn",@"BabyAgeUnder1Year",@"BabyAgeUnder2Years",@"BabyAgeUnder3Years"] objectAtIndex:enum]


@interface Settings : NSObject

@property (nonatomic, strong) NSDate *babyBirthDate;
@property (nonatomic, readonly) BabyAge babyAge;

+ (instancetype)sharedInstance;
- (NSString *)youtubePlaylistIdForBabyAge:(BabyAge)age;

@end
