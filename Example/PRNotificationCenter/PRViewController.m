//
//  PRViewController.m
//  PRNotificationCenter
//
//  Created by Juanjo Ramos on 10/01/2015.
//  Copyright (c) 2015 Juanjo Ramos. All rights reserved.
//

#import "PRViewController.h"

#import "PRNotificationDelegate.h"
#import "PRViewObserver.h"

#import <PRNotificationCenter/PRNotificationCenter.h>

NSString *const kNotificationName = @"notification";

@interface PRViewController () <UIPickerViewDataSource, UIPickerViewDelegate, PRNotificationDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *pickerOne;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerTwo;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerThree;

@property (weak, nonatomic) IBOutlet PRViewObserver *viewOne;
@property (weak, nonatomic) IBOutlet PRViewObserver *viewTwo;
@property (weak, nonatomic) IBOutlet PRViewObserver *viewThree;

@property (weak, nonatomic) IBOutlet UILabel *labelOne;
@property (weak, nonatomic) IBOutlet UILabel *labelTwo;
@property (weak, nonatomic) IBOutlet UILabel *labelThree;

@property (nonatomic, strong) NSDate *notificationDate;
@property (nonatomic, strong) NSArray *pickerData;
@property (nonatomic, strong) NSDictionary *priorityMap;

@end

@implementation PRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pickerData = @[@"Low", @"Medium", @"High"];
    
    self.priorityMap = @{@"Low": @(PRNotificationPriorityLow),
                         @"Medium": @(PRNotificationPriorityDefault),
                         @"High": @(PRNotificationPriorityHigh)};
	
    [self.viewOne setBackgroundColor:[UIColor clearColor]];
    [self.viewOne setNotificationColor:[UIColor blueColor]];
    [self.viewOne setDelegate:self];
    
    [self.viewTwo setBackgroundColor:[UIColor clearColor]];
    [self.viewTwo setNotificationColor:[UIColor yellowColor]];
    [self.viewTwo setDelegate:self];
    
    [self.viewThree setBackgroundColor:[UIColor clearColor]];
    [self.viewThree setNotificationColor:[UIColor redColor]];
    [self.viewThree setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)notifyObservers:(id)sender
{
    self.notificationDate = [NSDate date];
 
    [self _removeObservers];
    [self _addObservers];
    
    [[PRNotificationCenter defaultCenter] postNotificationName:kNotificationName object:self];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 3;
}

#pragma mark - UIPickerViewDelegate

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.pickerData[row];
}

#pragma mark - PRNotificationDelegate

- (void)observer:(PRViewObserver *)observer didReceiveNotification:(NSNotification *)notification
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.notificationDate];
    NSString *text = [NSString stringWithFormat:@"%.5f s", timeInterval];

    if (observer == self.viewOne) {
        [self.labelOne setText:text];
    }
    else if (observer == self.viewTwo) {
        [self.labelTwo setText:text];
    }
    else if (observer == self.viewThree) {
        [self.labelThree setText:text];
    }
    
//    if (observer == self.observerViewOne) {
//        [self.labelOne setText:text];
//    }
//    else if (observer == self.observerViewTwo) {
//        [self.labelTwo setText:text];
//    }
//    else if (observer == self.observerViewThree) {
//        [self.labelThree setText:text];
//    }
}

#pragma mark - Private Methods

- (void)_removeObservers
{
    [self.viewOne reset];
    [self.viewTwo reset];
    [self.viewThree reset];
    
    [[PRNotificationCenter defaultCenter] removeObserver:self.viewOne];
    [[PRNotificationCenter defaultCenter] removeObserver:self.viewTwo];
    [[PRNotificationCenter defaultCenter] removeObserver:self.viewThree];
}

- (void)_addObservers
{
    PRNotificationPriority priorityOne = [self.priorityMap[[self _selectedObjectInPickerView:self.pickerOne]] unsignedIntegerValue];
    PRNotificationPriority priorityTwo = [self.priorityMap[[self _selectedObjectInPickerView:self.pickerTwo]] unsignedIntegerValue];
    PRNotificationPriority priorityThree = [self.priorityMap[[self _selectedObjectInPickerView:self.pickerThree]] unsignedIntegerValue];
    
    [[PRNotificationCenter defaultCenter] addObserver:self.viewOne
                                             selector:@selector(notificationReceived:)
                                                 name:kNotificationName
                                               object:self priority:priorityOne];
    
    [[PRNotificationCenter defaultCenter] addObserver:self.viewTwo
                                             selector:@selector(notificationReceived:)
                                                 name:kNotificationName
                                               object:self priority:priorityTwo];
    
    [[PRNotificationCenter defaultCenter] addObserver:self.viewThree
                                             selector:@selector(notificationReceived:)
                                                 name:kNotificationName
                                               object:self priority:priorityThree];
}

- (NSString *)_selectedObjectInPickerView:(UIPickerView *)pickerView
{
    NSInteger row = [pickerView selectedRowInComponent:0];
    return self.pickerData[row];
}

@end
