//
//  HWDatePicker.h
//  HWExtension
//
//  Created by houwen.wang on 2016/12/6.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+Category.h"
#import "NSDate+Category.h"

/*
 * support the following formatter keywords:
 *
 *      formatter keywords          type
 *      ------------------         ------
 *             y/Y                   年
 *              M                    月
 *             d/D                   日
 *              h                    时（12小时制）
 *              H                    时（24小时制）
 *              m                    分
 *              s                    秒     */

@protocol HWDatePickerDelegate;

@interface HWDatePicker : UIView

- (instancetype)initWithMinimumDate:(NSDate *)minimumDate maximumDate:(NSDate *)maximumDate;

@property (nonatomic, strong) NSDate *minimumDate;   // max
@property (nonatomic, strong) NSDate *maximumDate;   // min

// 默认 HWDatePicker instance creat date
@property (nonatomic, strong) NSDate *selectedDate;

// 自定义行高，如果代理方法 "rowHeightForComponent" 被实现了，代理方法将优先被考虑
@property (nonatomic, assign) CGFloat rowHeight;        // 默认 25.0

// 自定义文字颜色，如果代理方法 "textAttributeForComponent" 被实现了，代理方法将优先被考虑
@property (nonatomic, strong) UIColor *textColor;     // 默认 black

// 自定义文字字体，如果代理方法 "textAttributeForComponent" 被实现了，代理方法将优先被考虑
@property (nonatomic, strong) UIFont *textFont;       // 默认 [UIFont systemFontOfSize:15]

// 日期格式，必须以 "/" 作为分隔符，e.g. YYYY年/MM月/dd日/HH时/mm分/ss秒, default is @"YYYY年/MM月/dd日"
@property (nonatomic, copy) NSString *dateFormatter;

@property (nonatomic, weak) id <HWDatePickerDelegate> delegate;    // delegate

@end

@protocol HWDatePickerDelegate <NSObject>

@optional

// 自定义行高
- (CGFloat)pickerView:(HWDatePicker *)pickerView rowHeightForComponent:(NSInteger)component;

//  component 富文本属性
- (NSDictionary *)pickerView:(HWDatePicker *)pickerView textAttributeForComponent:(NSInteger)component;

//  日期变化回调
- (void)pickerViewSelectDateDidChanged:(HWDatePicker *)pickerView newDate:(NSDate *)newDate;

@end
