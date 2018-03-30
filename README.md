# HWDatePicker

[![CI Status](http://img.shields.io/travis/wanghouwen/HWDatePicker.svg?style=flat)](https://travis-ci.org/wanghouwen/HWDatePicker)
[![Version](https://img.shields.io/cocoapods/v/HWDatePicker.svg?style=flat)](http://cocoapods.org/pods/HWDatePicker)
[![License](https://img.shields.io/cocoapods/l/HWDatePicker.svg?style=flat)](http://cocoapods.org/pods/HWDatePicker)
[![Platform](https://img.shields.io/cocoapods/p/HWDatePicker.svg?style=flat)](http://cocoapods.org/pods/HWDatePicker)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## How to use

Import the class header.

``` objective-c
#import "HWDatePicker.h"
```

create date picker view and add to supperview.

``` objective-c
CGSize screenSize = [UIScreen mainScreen].bounds.size;

HWDatePicker *datePicker = [[HWDatePicker alloc] initWithFrame:CGRectMake(0, screenSize.height - 300, screenSize.width, 300)];
datePicker.backgroundColor = [UIColor whiteColor];
datePicker.dateFormatter = @"YYYY年/MM月/dd日/HH时/mm分"; // 可不设置，有默认值
datePicker.minimumDate = [NSDate date]; // 可不设置
datePicker.maximumDate = [[NSDate date] dateByAddingTimeInterval:24 * 3600 * 10]; // 可不设置
datePicker.delegate = self; // 可不设置

[self.view addSubview:datePicker];
```

customize it to your own style.

``` objective-c
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
```

## Requirements

## Installation

HWDatePicker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'HWDatePicker'
```

## Author

wanghouwen, wanghouwen123@126.com

## License

HWDatePicker is available under the MIT license. See the LICENSE file for more info.
