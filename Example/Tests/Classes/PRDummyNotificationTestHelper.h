//
//  PRDummyNotificationTestHelper.h
//  PRNotificationCenter
//
//  Created by Juanjo Ramos on 01/10/2015.
//  Copyright (c) 2015 Agile Sports Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRDummyNotificationTestHelper : NSObject

- (instancetype)initWithCompletionBlock:(void(^)(PRDummyNotificationTestHelper *))completionBlock;

- (void)notificationSelector;
- (void)notificationSelector:(NSNotification *)notification;

@end
