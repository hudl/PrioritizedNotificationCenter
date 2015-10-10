//
//  PRViewObserver.m
//  PRNotificationCenter
//
//  Created by Juanjo Ramos Rodriguez on 10/10/15.
//  Copyright © 2015 Agile Sports Technologies. All rights reserved.
//

#import "PRViewObserver.h"

@implementation PRViewObserver

- (void)reset
{
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)notificationReceived:(NSNotification *)notification
{
    [self setBackgroundColor:self.notificationColor];
    
    [self.delegate observer:self didReceiveNotification:notification];
}

@end
