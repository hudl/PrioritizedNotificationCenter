//
//  PRViewObserver.h
//  PRNotificationCenter
//
//  Created by Juanjo Ramos Rodriguez on 10/10/15.
//  Copyright © 2015 Agile Sports Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PRNotificationDelegate.h"

@interface PRViewObserver : UIView

@property (nonatomic, strong) UIColor *notificationColor;
@property (nonatomic, weak) id<PRNotificationDelegate> delegate;

- (void)reset;
- (void)notificationReceived:(NSNotification *)notification;

@end
