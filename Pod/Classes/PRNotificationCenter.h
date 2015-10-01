//
//  PRNotificationCenter.h
//  Pods
//
//  Created by Juanjo Ramos on 01/10/2015.
//  Copyright (c) 2015 Agile Sports Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NotificationPriority) {
    NotificationPriorityLow = 0,
    NotificationPriorityDefault = 5,
    NotificationPriorityHigh = 10
};
/*!
 @constants
 `NotificationPriorityLow`
 `NotificationPriorityDefault`
 `NotificationPriorityHigh`
 */

/*!
 @header PRNotificationCenter
 
 @discussion PRNotificationCenter object leverages NSNotificationCenter to provide a mechanism to register different observers for the same notification with a priority value.
 PRNotificationCenter ensures that when a notification is posted, those observers registered with a higher priority will be notified first.
 For observers registered with the same priority value, the order in which they are notified is undefined.
 APIs pretty much match those offered by NSNotificationCenter.
 */
@interface PRNotificationCenter : NSObject

+ (instancetype)defaultCenter;

/*!
 Adds an observer with a priority value NotificationPriorityDefault.
 Same warnings and rules when dealing with observers apply as the ones specified in NSNotificationCenter.
 
 @see NSNotificationCenter for description about the parameters
 */
- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject;

/*!
 Adds an observer with the specified priority value.
 Same warnings and rules when dealing with observers apply as the ones specified in NSNotificationCenter.
 @discussion Observers with higher priority will be notified first. If two observers are added with the same priority value, the order in which they will be notified is undefined
 
 @param priority.
 @see NSNotificationCenter for description about the other parameters
 */
- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject priority:(NotificationPriority)priority;

// TODO:
//- (id<NSObject> _Nonnull)addObserverForName:(NSString * _Nullable)name object:(id _Nullable)obj queue:(NSOperationQueue * _Nullable)queue usingBlock:(void (^ _Nonnull)(NSNotification * _Nonnull note))block

/*!
 Creates a notification. Observers will be notified based on the priority value they were added with.
 
 @see NSNotificationCenter for description about the other parameters
 */
- (void)postNotificationName:(NSString *)aName object:(id)anObject;

/*!
 Creates a notification. Observers will be notified based on the priority value they were added with.
 
 @see NSNotificationCenter for description about the other parameters
 */
- (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

/*!
 
 @see NSNotificationCenter
 */
- (void)removeObserver:(id)observer;

/*!
 
 @see NSNotificationCenter
 */
- (void)removeObserver:(id)observer name:(NSString *)aName object:(id)anObject;

@end
