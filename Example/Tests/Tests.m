//
//  PRNotificationCenterTests.m
//  PRNotificationCenterTests
//
//  Created by Juanjo Ramos on 10/01/2015.
//  Copyright (c) 2015 Juanjo Ramos. All rights reserved.
//

@import XCTest;
#import "PRDummyNotificationTestHelper.h"
#import "PRNotificationCenter.h"

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// This test adds 100 observers of every priority level and checks that they are notified in the right order
- (void)testaddingObservers
{
    NSString *notificationName = @"NotificationTest";
    
    NSMutableArray *lowPrio = [[NSMutableArray alloc] initWithCapacity:100];
    NSMutableArray *defaultPrio = [[NSMutableArray alloc] initWithCapacity:100];
    NSMutableArray *highPrio = [[NSMutableArray alloc] initWithCapacity:100];
    // Create 100 low priority observers
    void (^completionBlockLow)(PRDummyNotificationTestHelper *) = ^(PRDummyNotificationTestHelper *object) {
        NSAssert(defaultPrio.count == 0, @"All notifications with default priority should have been fired by now");
        NSAssert(highPrio.count == 0, @"All notifications with high priority should have been fired by now");
        [lowPrio removeObject:object];
    };
    for (int i = 0; i < 100; i++)
    {
        PRDummyNotificationTestHelper *notificationHelper = [[PRDummyNotificationTestHelper alloc] initWithCompletionBlock:completionBlockLow];
        [lowPrio addObject:notificationHelper];
        
        [[PRNotificationCenter defaultCenter] addObserver:notificationHelper
                                                 selector:@selector(notificationSelector)
                                                     name:notificationName
                                                   object:self
                                                 priority:PRNotificationPriorityLow];
    }
    
    // Create 100 default priority
    void (^completionBlockDefault)(PRDummyNotificationTestHelper *) = ^(PRDummyNotificationTestHelper *object) {
        NSAssert(highPrio.count == 0, @"All notifications with high priority should have been fired by now");
        NSAssert(lowPrio.count == 100, @"None notifications with low priority should have been fired at this point");
        [defaultPrio removeObject:object];
    };
    for (int i = 0; i < 100; i++)
    {
        PRDummyNotificationTestHelper *notificationHelper = [[PRDummyNotificationTestHelper alloc] initWithCompletionBlock:completionBlockDefault];
        [defaultPrio addObject:notificationHelper];
        
        [[PRNotificationCenter defaultCenter] addObserver:notificationHelper
                                                 selector:@selector(notificationSelector)
                                                     name:notificationName
                                                   object:self
                                                 priority:PRNotificationPriorityDefault];
    }
    
    // Create 100 high priority
    void (^completionBlockHigh)(PRDummyNotificationTestHelper *) = ^(PRDummyNotificationTestHelper *object) {
        NSAssert(lowPrio.count == 100, @"None notifications with low priority should have been fired at this point");
        NSAssert(defaultPrio.count == 100, @"None notifications with default priority should have been fired at this point");
        [highPrio removeObject:object];
    };
    for (int i = 0; i < 100; i++)
    {
        PRDummyNotificationTestHelper *notificationHelper = [[PRDummyNotificationTestHelper alloc] initWithCompletionBlock:completionBlockHigh];
        [highPrio addObject:notificationHelper];
        
        [[PRNotificationCenter defaultCenter] addObserver:notificationHelper
                                                 selector:@selector(notificationSelector)
                                                     name:notificationName
                                                   object:self
                                                 priority:PRNotificationPriorityHigh];
    }
    
    // Post notification
    [[PRNotificationCenter defaultCenter] postNotificationName:notificationName object:self];
}

// This test ensures that HudlNotificationCenter can handle adding observers in a concurrent fashion.
// It adds different observers to the different priority level and check that the number matches in the end.
- (void)testAddingObserversInParallel
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Description"];
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0);
    NSString *notificationName = @"NotificationTestParallel";
    
    // Holding strong references to the notification objects to make sure they are not deallocated
    // and deregistered
    NSMutableArray *lows = [NSMutableArray new];
    NSMutableArray *meds = [NSMutableArray new];
    NSMutableArray *highs = [NSMutableArray new];
    
    __block NSInteger counter = 0;
    void (^completionBlock)(PRDummyNotificationTestHelper *) = ^(PRDummyNotificationTestHelper *helper) {
        counter++;
    };
    
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 100; i++)
        {
            PRDummyNotificationTestHelper *notificationHelper = [[PRDummyNotificationTestHelper alloc] initWithCompletionBlock:completionBlock];
            
            [lows addObject:notificationHelper];
            
            [[PRNotificationCenter defaultCenter] addObserver:notificationHelper
                                                     selector:@selector(notificationSelector)
                                                         name:notificationName
                                                       object:self
                                                     priority:PRNotificationPriorityLow];
        }
    });
    
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 100; i++)
        {
            PRDummyNotificationTestHelper *notificationHelper = [[PRDummyNotificationTestHelper alloc] initWithCompletionBlock:completionBlock];
            
            [meds addObject:notificationHelper];
            
            [[PRNotificationCenter defaultCenter] addObserver:notificationHelper
                                                     selector:@selector(notificationSelector)
                                                         name:notificationName
                                                       object:self
                                                     priority:PRNotificationPriorityDefault];
        }
    });
    
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 100; i++)
        {
            PRDummyNotificationTestHelper *notificationHelper = [[PRDummyNotificationTestHelper alloc] initWithCompletionBlock:completionBlock];
            
            [highs addObject:notificationHelper];
            
            [[PRNotificationCenter defaultCenter] addObserver:notificationHelper
                                                     selector:@selector(notificationSelector)
                                                         name:notificationName
                                                       object:self
                                                     priority:PRNotificationPriorityHigh];
        }
    });
    
    dispatch_group_notify(group, queue, ^{
        // Post notification
        [[PRNotificationCenter defaultCenter] postNotificationName:notificationName object:self];
        if (counter == 300)
        {
            [expectation fulfill];
        }
        else
        {
            NSLog(@"We should have received 300 notifications but we received: <%ld>", counter);
        }
    });
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        NSLog(@"Timeout. Error: <%@>", error.localizedDescription);
    }];
}

// This test checks that HudlNoticationCenter can handle the addition and removal of observers as expected
- (void)testAddingAndRemovingObservers
{
    NSString *notificationName = @"NotificationTestAddRemove";
    
    __block NSInteger counter = 0;
    void (^completionBlock)(PRDummyNotificationTestHelper *) = ^(PRDummyNotificationTestHelper *helper) {
        counter++;
    };
    
    PRDummyNotificationTestHelper *notificationHelperAdd = [[PRDummyNotificationTestHelper alloc] initWithCompletionBlock:completionBlock];
    PRDummyNotificationTestHelper *notificationHelperRemove = [[PRDummyNotificationTestHelper alloc] initWithCompletionBlock:completionBlock];
    
    [[PRNotificationCenter defaultCenter] addObserver:notificationHelperAdd
                                             selector:@selector(notificationSelector)
                                                 name:notificationName
                                               object:self
                                             priority:PRNotificationPriorityLow];
    
    [[PRNotificationCenter defaultCenter] addObserver:notificationHelperRemove
                                             selector:@selector(notificationSelector)
                                                 name:notificationName
                                               object:self
                                             priority:PRNotificationPriorityLow];
    
    [[PRNotificationCenter defaultCenter] removeObserver:notificationHelperRemove
                                                    name:notificationName
                                                  object:self];
    
    [[PRNotificationCenter defaultCenter] postNotificationName:notificationName object:self];
    XCTAssert(counter == 1, @"Counter should be 1 and it is %@", @(counter));
}

// This test adds and removes observers to HudlNotificationCenter in a concurrent fashion and checks that the number
// of notifications received matches the expected number
- (void)testAddingAndRemovingObserversInParallel
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Description"];
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0);
    NSString *notificationName = @"NotificationTestParallel";
    
    __block NSInteger counterLows = 0;
    __block NSInteger counterMeds = 0;
    __block NSInteger counterHighs = 0;
    void (^completionBlockLows)(PRDummyNotificationTestHelper *) = ^(PRDummyNotificationTestHelper *helper) {
        counterLows++;
    };
    void (^completionBlockMeds)(PRDummyNotificationTestHelper *) = ^(PRDummyNotificationTestHelper *helper) {
        counterMeds++;
    };
    void (^completionBlockHighs)(PRDummyNotificationTestHelper *) = ^(PRDummyNotificationTestHelper *helper) {
        counterHighs++;
    };
    
    NSMutableArray *firstLows = [NSMutableArray new];
    NSMutableArray *firstMeds = [NSMutableArray new];
    NSMutableArray *firstHighs = [NSMutableArray new];
    
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 100; i++)
        {
            PRDummyNotificationTestHelper *notificationHelper = [[PRDummyNotificationTestHelper alloc] initWithCompletionBlock:completionBlockLows];
            
            [firstLows addObject:notificationHelper];
            
            [[PRNotificationCenter defaultCenter] addObserver:notificationHelper
                                                     selector:@selector(notificationSelector)
                                                         name:notificationName
                                                       object:self
                                                     priority:PRNotificationPriorityLow];
        }
    });
    
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 200; i++)
        {
            PRDummyNotificationTestHelper *notificationHelper = [[PRDummyNotificationTestHelper alloc] initWithCompletionBlock:completionBlockMeds];
            
            [firstMeds addObject:notificationHelper];
            
            [[PRNotificationCenter defaultCenter] addObserver:notificationHelper
                                                     selector:@selector(notificationSelector)
                                                         name:notificationName
                                                       object:self
                                                     priority:PRNotificationPriorityDefault];
        }
    });
    
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 1000; i++)
        {
            PRDummyNotificationTestHelper *notificationHelper = [[PRDummyNotificationTestHelper alloc] initWithCompletionBlock:completionBlockHighs];
            
            [firstHighs addObject:notificationHelper];
            
            [[PRNotificationCenter defaultCenter] addObserver:notificationHelper
                                                     selector:@selector(notificationSelector)
                                                         name:notificationName
                                                       object:self
                                                     priority:PRNotificationPriorityHigh];
        }
    });
    
    dispatch_group_notify(group, queue, ^{
        dispatch_group_async(group, queue, ^{
            for (int i = 0; i < 50; i++)
            {
                PRDummyNotificationTestHelper *notificationHelper = [firstLows objectAtIndex:i];
                
                [[PRNotificationCenter defaultCenter] removeObserver:notificationHelper
                                                                name:notificationName
                                                              object:self];
            }
        });
        
        dispatch_group_async(group, queue, ^{
            for (int i = 0; i < 20; i++)
            {
                PRDummyNotificationTestHelper *notificationHelper = [[PRDummyNotificationTestHelper alloc] initWithCompletionBlock:completionBlockLows];
                
                [firstLows addObject:notificationHelper];
                
                [[PRNotificationCenter defaultCenter] addObserver:notificationHelper
                                                         selector:@selector(notificationSelector)
                                                             name:notificationName
                                                           object:self
                                                         priority:PRNotificationPriorityLow];
            }
        });
        
        dispatch_group_async(group, queue, ^{
            for (int i = 0; i < 70; i++)
            {
                PRDummyNotificationTestHelper *notificationHelper = [firstMeds objectAtIndex:i];
                
                [[PRNotificationCenter defaultCenter] removeObserver:notificationHelper
                                                                name:notificationName
                                                              object:self];
            }
        });
        
        dispatch_group_async(group, queue, ^{
            for (int i = 0; i < 50; i++)
            {
                PRDummyNotificationTestHelper *notificationHelper = [[PRDummyNotificationTestHelper alloc] initWithCompletionBlock:completionBlockMeds];
                
                [firstMeds addObject:notificationHelper];
                
                [[PRNotificationCenter defaultCenter] addObserver:notificationHelper
                                                         selector:@selector(notificationSelector)
                                                             name:notificationName
                                                           object:self
                                                         priority:PRNotificationPriorityDefault];
            }
        });
        
        dispatch_group_async(group, queue, ^{
            for (int i = 0; i < 100; i++)
            {
                PRDummyNotificationTestHelper *notificationHelper = [firstHighs objectAtIndex:i];
                
                [[PRNotificationCenter defaultCenter] removeObserver:notificationHelper
                                                                name:notificationName
                                                              object:self];
            }
        });
        
        dispatch_group_async(group, queue, ^{
            for (int i = 0; i < 10; i++)
            {
                PRDummyNotificationTestHelper *notificationHelper = [[PRDummyNotificationTestHelper alloc] initWithCompletionBlock:completionBlockHighs];
                
                [firstHighs addObject:notificationHelper];
                
                [[PRNotificationCenter defaultCenter] addObserver:notificationHelper
                                                         selector:@selector(notificationSelector)
                                                             name:notificationName
                                                           object:self
                                                         priority:PRNotificationPriorityHigh];
            }
        });
        
        dispatch_group_notify(group, queue, ^{
            // Post notification
            [[PRNotificationCenter defaultCenter] postNotificationName:notificationName object:self];
            BOOL lowsOk = (counterLows == 70);
            if (!lowsOk)
            {
                NSLog(@"We should have received 70 notifications for low objects but we received: <%ld>", counterLows);
            }
            BOOL medsOk = (counterMeds == 180);
            if (!medsOk)
            {
                NSLog(@"We should have received 180 notifications for med objects but we received: <%ld>", counterMeds);
            }
            BOOL highsOk = (counterHighs == 910);
            if (!highsOk)
            {
                NSLog(@"We should have received 910 notifications for high objects but we received: <%ld>", counterHighs);
            }
            if (lowsOk && medsOk && highsOk)
            {
                [expectation fulfill];
            }
        });
    });
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error)
        {
            NSLog(@"Timeout. Error: %@", error.localizedDescription);
        }
        XCTAssert(!error);
    }];
}

@end

