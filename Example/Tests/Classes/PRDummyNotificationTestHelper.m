//
//  PRDummyNotificationTestHelper.m
//  PRNotificationCenter
//
//  Created by Juanjo Ramos on 01/10/2015.
//  Copyright (c) 2015 Agile Sports Technologies. All rights reserved.
//

#import "PRDummyNotificationTestHelper.h"
#import "PRNotificationCenter.h"

@interface PRDummyNotificationTestHelper ()

@property (nonatomic, copy) void(^completionBlock)(PRDummyNotificationTestHelper *);

@end

@implementation PRDummyNotificationTestHelper

- (instancetype)initWithCompletionBlock:(void(^)(PRDummyNotificationTestHelper *))completionBlock
{
    if (self = [super init]) {
        self.completionBlock = completionBlock;
        
        return self;
    }
    
    return nil;
}

- (void)dealloc
{
    [[PRNotificationCenter defaultCenter] removeObserver:self];
}

- (void)notificationSelector
{
    [self notificationSelector:nil];
}

- (void)notificationSelector:(NSNotification *)notification
{
    NSAssert(self.completionBlock, @"I should have a completion block");
    
    __weak typeof(self) weakSelf = self;
    self.completionBlock(weakSelf);
}

@end
