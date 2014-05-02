//
//  Settings.m
//  ParentsAcademy
//
//  Created by Alex on 5/2/14.
//  Copyright (c) 2014 Alex Shevlyakov. All rights reserved.
//

#import "Settings.h"

@implementation Settings

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#warning Birth date doesn't save correctly

- (void)setBabyBirthDate:(NSDate *)babyBirthDate
{
    [self _set:@"BabyBirth" value:babyBirthDate];
}

- (NSDate *)babyBirthDate
{
    return [self _get:@"BabyBirth"];
}

- (BabyAge)babyAge
{
    if (!self.babyBirthDate) {
        return BabyAgeNotYetBorn;
    }
    
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar] 
        components:NSYearCalendarUnit
        fromDate:self.babyBirthDate
        toDate:[NSDate date]
        options:0];
    
    switch ([ageComponents year]) {
        case 0: return BabyAgeUnder1Year;
        case 1: return BabyAgeUnder2Years;
        case 2: return BabyAgeUnder3Years;
    }
    return BabyAgeUnder3Years;
}

- (NSDictionary *)settingForBabyAge:(BabyAge)age
{
    NSDictionary *playlists = (NSDictionary *)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Settings for baby age"];
    NSString *babyAgeKey = BabyAgeString(age);
    return [playlists objectForKey:babyAgeKey];
}

- (NSString *)youtubePlaylistIdForBabyAge:(BabyAge)age
{
    return [[self settingForBabyAge:age]  objectForKey:@"playlist"];
}

- (NSString *)pageTitleForBabyAge:(BabyAge)age
{
    return [[self settingForBabyAge:age]  objectForKey:@"title"];
}

#pragma mark - Helpers

#warning Remove debug logs

- (id)_get:(NSString *)key {
    NSUserDefaults *userDefs = [NSUserDefaults standardUserDefaults];
    NSLog(@"%@", [userDefs dictionaryRepresentation]);
    return [userDefs objectForKey:key];
}

- (void)_set:(NSString *)key value:(id)value {
    NSUserDefaults *userDefs = [NSUserDefaults standardUserDefaults];
    [userDefs setObject:value forKey:key];
    NSLog(@"%@", [userDefs dictionaryRepresentation]);
}

@end
