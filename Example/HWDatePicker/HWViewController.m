//
//  HWViewController.m
//  HWDatePicker
//
//  Created by wanghouwen on 03/29/2018.
//  Copyright (c) 2018 wanghouwen. All rights reserved.
//

#import "HWViewController.h"
#import "HWDatePicker.h"

@interface HWViewController () <HWDatePickerDelegate>

@end

@implementation HWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
	
    HWDatePicker *datePicker = [[HWDatePicker alloc] initWithFrame:CGRectMake(0, screenSize.height - 300, screenSize.width, 300)];
    datePicker.backgroundColor = [UIColor whiteColor];
    datePicker.dateFormatter = @"YYYY年/MM月/dd日/HH时/mm分";
    datePicker.minimumDate = [NSDate date];
    datePicker.maximumDate = [[NSDate date] dateByAddingTimeInterval:24 * 3600 * 10];
    datePicker.delegate = self;
    
    [self.view addSubview:datePicker];
}

#pragma mark -
#pragma mark HWDatePickerDelegate

- (CGFloat)pickerView:(HWDatePicker *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 44;
}

- (NSDictionary *)pickerView:(HWDatePicker *)pickerView textAttributeForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return @{NSForegroundColorAttributeName : [UIColor blueColor], NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    } else if (component == 1) {
        return @{NSForegroundColorAttributeName : [UIColor greenColor]};
    } else if (component == 2) {
        return @{NSForegroundColorAttributeName : [UIColor redColor]};
    } else if (component == 3) {
        return @{NSForegroundColorAttributeName : [UIColor orangeColor]};
    } else if (component == 4) {
       return @{NSForegroundColorAttributeName : [UIColor purpleColor]};
    }
    return nil;
}

- (void)pickerViewSelectDateDidChanged:(HWDatePicker *)pickerView newDate:(NSDate *)newDate
{
    NSLog(@"new date : %@", newDate);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
