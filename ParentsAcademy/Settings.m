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

- (void)setBabyBirthDate:(NSDate *)babyBirthDate
{
    [self _set:@"BabyBirth" value:babyBirthDate];
}

- (NSDate *)babyBirthDate
{
    return [self _get:@"BabyBirth"];
}

#pragma mark - Helpers

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
