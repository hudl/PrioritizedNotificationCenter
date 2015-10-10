//
//  PRNotificationDelegate.h
//  PRNotificationCenter
//
//  Created by Juanjo Ramos Rodriguez on 10/10/15.
//  Copyright © 2015 Agile Sports Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PRViewObserver;
@protocol PRNotificationDelegate <NSObject>

- (void)observer:(PRViewObserver *)observer didReceiveNotification:(NSNotification *)notification;

@end
