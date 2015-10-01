//
//  PRNotificationCenter.m
//  Pods
//
//  Created by Juanjo Ramos on 01/10/2015.
//  Copyright (c) 2015 Agile Sports Technologies. All rights reserved.
//

#import "PRNotificationCenter.h"

static dispatch_once_t token;
static PRNotificationCenter *__sharedInstance;
NSString *const kSeparator = @"_";

@interface PRNotificationCenter ()

// notificationsTable: {NotificationName: maptable}
// maptable: {0:array, 1:array, ..., 10:array}
@property (nonatomic, strong) NSMutableDictionary *notificationsDictionary;

@end

@implementation PRNotificationCenter

- (instancetype)init
{
    if (self = [super init])
    {
        self.notificationsDictionary = [NSMutableDictionary new];
        
        return self;
    }
    
    return nil;
}

+ (instancetype)defaultCenter
{
    dispatch_once(&token, ^{
        __sharedInstance = [[PRNotificationCenter alloc] init];
    });
    
    return __sharedInstance;
}

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject
{
    [self addObserver:observer selector:aSelector name:aName object:anObject priority:NotificationPriorityDefault];
}

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject priority:(NotificationPriority)priority
{
    // Ensure the maximum value for priority is never higher than NotificationPriorityHigh
    priority = MIN(priority, NotificationPriorityHigh);
    @synchronized(self.notificationsDictionary)
    {
        NSMutableDictionary *mapTable = [self.notificationsDictionary objectForKey:aName];
        if (!mapTable)
        {
            mapTable = [NSMutableDictionary new];
        }
        
        NSPointerArray *array = [mapTable objectForKey:@(priority)];
        if (!array)
        {
            array = [NSPointerArray weakObjectsPointerArray];
        }
        
        [array addPointer:(__bridge void *)observer];
        
        [mapTable setObject:array forKey:@(priority)];
        [self.notificationsDictionary setObject:mapTable forKey:aName];
        
        NSString *notificationValue = [self _notificationValueForName:aName priority:priority];
        [[NSNotificationCenter defaultCenter] addObserver:observer
                                                 selector:aSelector
                                                     name:notificationValue
                                                   object:anObject];
    }
}

- (void)postNotificationName:(NSString *)aName object:(id)anObject
{
    [self postNotificationName:aName object:anObject userInfo:nil];
}

- (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo
{
    @synchronized(self.notificationsDictionary)
    {
        NSDictionary *mapTable = self.notificationsDictionary[aName];
        if (!mapTable)
        {
            return;
        }
        
        NSArray *keys = [[mapTable.allKeys copy] sortedArrayUsingComparator:^NSComparisonResult (NSNumber *obj1, NSNumber *obj2) {
            if (obj2.unsignedIntegerValue < obj1.unsignedIntegerValue)
            {
                return NSOrderedAscending;
            }
            else if (obj2.unsignedIntegerValue > obj1.unsignedIntegerValue)
            {
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        }];
        
        for (NSNumber *number in keys)
        {
            NSString *notificationValue = [self _notificationValueForName:aName priority:number.unsignedIntegerValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationValue
                                                                object:anObject
                                                              userInfo:aUserInfo];
        }
    }
}

- (void)removeObserver:(id)observer
{
    NSArray *notitificationNames = [self.notificationsDictionary.allKeys copy];
    for (NSString *name in notitificationNames)
    {
        [self removeObserver:observer name:name object:nil];
    }
}

- (void)removeObserver:(id)observer name:(NSString *)aName object:(id)anObject
{
    @synchronized(self.notificationsDictionary)
    {
        if (!aName)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
            return;
        }
        
        NSString *notificationValue;
        if (aName)
        {
            notificationValue = [self _removeObserver:observer name:aName];
            if (notificationValue)
            {
                [[NSNotificationCenter defaultCenter] removeObserver:observer name:notificationValue object:anObject];
            }
            else
            {
                [[NSNotificationCenter defaultCenter] removeObserver:observer];
            }
        }
        
        if ([self.notificationsDictionary[aName] count] == 0)
        {
            [self.notificationsDictionary removeObjectForKey:aName];
        }
    }
}

#pragma mark - Private Methods

- (NSString *)_notificationValueForName:(NSString *)name priority:(NotificationPriority)priority
{
    return [NSString stringWithFormat:@"%@%@%@", name, kSeparator, @(priority)];
}

- (NSString *)_removeObserver:(id)observer name:(NSString *)aName
{
    NSMutableDictionary *mapTable = self.notificationsDictionary[aName];
    NotificationPriority priority = NSUIntegerMax;
    if (!mapTable)
    {
        NSLog(@"Warning. Normally I would expect a mapTable available for notification: %@", aName);
        return nil;
    }
    
    // Look in all possible keys
    for (uint priorityIterator = NotificationPriorityLow; priorityIterator <= NotificationPriorityHigh; priorityIterator++)
    {
        NSPointerArray *array = [mapTable[@(priorityIterator)] copy];
        if (!array)
        {
            continue;
        }
        
        // Iterate over all observers registered at any given priority
        NSUInteger count = array.count;
        for (NSUInteger i = 0; i < count; i++)
        {
            id pointer = [array pointerAtIndex:i];
            if (pointer == observer)
            {
                [array removePointerAtIndex:i];
                priority = priorityIterator;
                break;
            }
        }
        
        [array compact];
        
        // If the array does not contain any pointers, clear that key
        if (array.count > 0)
        {
            mapTable[@(priorityIterator)] = array;
        }
        else
        {
            [mapTable removeObjectForKey:@(priorityIterator)];
        }
    }
    
    if ((NSUInteger)priority != NSUIntegerMax)
    {
        return [self _notificationValueForName:aName priority:priority];
    }
    else
    {
        return nil;
    }
}

@end
