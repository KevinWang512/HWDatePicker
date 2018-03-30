//
//  HWDatePicker.m
//  HWExtension
//
//  Created by houwen.wang on 2016/12/6.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import "HWDatePicker.h"
#import "NSString+Category.h"
#import "NSDate+Category.h"

#define kMaxYearCount (2000 * 99)

#define AssertMaxAndMinDate(max, min)   \
if (max && min) { \
if ([min timeIntervalSince1970] > [max timeIntervalSince1970]) {    \
@throw [NSException exceptionWithName:@"param error" reason:@"max < min" userInfo:@{@"Max Date" : max, @"Min Date" : min}]; \
}   \
}

void *HWDatePickerObserverContext = &HWDatePickerObserverContext;

@interface HWDateFormatComponent : NSObject

@property (nonatomic, copy) NSString *dateFormat;               //
@property (nonatomic, assign) NSCalendarUnit unit;              //
@property (nonatomic, assign) NSInteger index;                  //
@property (nonatomic, copy, readonly) NSString *normalFormat;   //

@end

@implementation HWDateFormatComponent

- (instancetype)init {
    if (self=[super init]) {
        self.index = -999;
    }
    return self;
}

- (void)setDateFormat:(NSString *)dateFormat {
    if (![_dateFormat isEqualToString:dateFormat]) {
        _dateFormat = dateFormat ? [dateFormat copy] : nil;
        // 年
        if ([dateFormat.uppercaseString rangeOfString:@"Y"].length) {
            self.unit = NSCalendarUnitYear;
        }// 月
        else if ([dateFormat rangeOfString:@"M"].length){
            self.unit = NSCalendarUnitMonth;
        }// 日
        else if ([dateFormat.uppercaseString rangeOfString:@"D"].length){
            self.unit = NSCalendarUnitDay;
        }// 时
        else if ([dateFormat.uppercaseString rangeOfString:@"H"].length){
            self.unit = NSCalendarUnitHour;
        }// 分
        else if ([dateFormat rangeOfString:@"m"].length){
            self.unit = NSCalendarUnitMinute;
        }// 秒
        else if ([dateFormat rangeOfString:@"s"].length){
            self.unit = NSCalendarUnitSecond;
        }
    }
}

- (NSString *)normalFormat {
    // 年
    if ([self.dateFormat.uppercaseString rangeOfString:@"Y"].length) {
        return @"YYYY";
    }// 月
    else if ([self.dateFormat rangeOfString:@"M"].length){
        return @"MM";
    }// 日
    else if ([self.dateFormat rangeOfString:@"d"].length){
        return @"dd";
    }// 时
    else if ([self.dateFormat rangeOfString:@"H"].length){
        return @"HH";
    }// 时
    else if ([self.dateFormat rangeOfString:@"h"].length){
        return @"hh";
    }// 分
    else if ([self.dateFormat rangeOfString:@"m"].length){
        return @"mm";
    }// 秒
    else if ([self.dateFormat rangeOfString:@"s"].length){
        return @"ss";
    }// 毫秒
    else if ([self.dateFormat rangeOfString:@"S"].length){
        return @"SSS";
    }
    return @"";
}

@end

@interface HWDatePicker ()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, assign) NSUInteger year;      //
@property (nonatomic, assign) NSUInteger month;     //
@property (nonatomic, assign) NSUInteger day;       //
@property (nonatomic, assign) NSUInteger hour;      //
@property (nonatomic, assign) NSUInteger minute;    //
@property (nonatomic, assign) NSUInteger second;    //

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSCalendar *calendar;         //
@property (nonatomic, copy) NSString *normalFormat;         //

@property (nonatomic, strong) NSMutableArray <HWDateFormatComponent *>*dateFormatComponents;  //

@property (nonatomic, copy) NSString *layoutSubviewsKey;    //

@end

@implementation HWDatePicker

- (instancetype)init {
    if (self=[super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithMinimumDate:(NSDate *)minimumDate maximumDate:(NSDate *)maximumDate {
    if (self=[super init]) {
        [self setup];
        AssertMaxAndMinDate(maximumDate, minimumDate);
        self.minimumDate = minimumDate;
        self.maximumDate = maximumDate;
    }
    return self;
}

- (void)setup {
    if (self.pickerView == nil) {
        
        self.dateFormatComponents = [NSMutableArray array];
        
        self.rowHeight = 25.0;
        self.textFont = [UIFont systemFontOfSize:15];
        self.textColor = [UIColor blackColor];
        
        self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        self.calendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:28800];
        
        self.pickerView = [[UIPickerView alloc] init];
        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        self.pickerView.showsSelectionIndicator = YES;
        [self addSubview:self.pickerView];
        
        [self addObserveForKeyPaths:@[@"year",@"month",@"day",@"hour",@"minute",@"second"]];
        
        self.dateFormatter = @"YYYY年/MM月/dd日";
        self.selectedDate = [NSDate date];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *, id> *)change
                       context:(void *)context {
    
    if (context == HWDatePickerObserverContext) {
        NSInteger new = [change[NSKeyValueChangeNewKey] integerValue];
        NSDictionary <NSString *,NSNumber *>*componentMap = @{@"year":@(NSCalendarUnitYear),
                                                              @"month":@(NSCalendarUnitMonth),
                                                              @"day":@(NSCalendarUnitDay),
                                                              @"hour":@(NSCalendarUnitHour),
                                                              @"minute":@(NSCalendarUnitMinute),
                                                              @"second":@(NSCalendarUnitSecond)
                                                              };
        [self setComponentValue:new forComponentType:[componentMap[keyPath] integerValue]];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// 回调代理
- (void)callbackDelegate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickerViewSelectDateDidChanged:newDate:)]) {
        [self.delegate pickerViewSelectDateDidChanged:self newDate:self.selectedDate];
    }
}

#pragma mark - setter

- (void)setRowHeight:(CGFloat)rowHeight {
    if (_rowHeight != rowHeight) {
        _rowHeight = rowHeight;
        [self.pickerView reloadAllComponents];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    if (_textColor != textColor) {
        _textColor = textColor;
        [self.pickerView reloadAllComponents];
    }
}

- (void)setTextFont:(UIFont *)textFont {
    if (_textFont != textFont) {
        _textFont = textFont;
        [self.pickerView reloadAllComponents];
    }
}

- (void)setSelectedDate:(NSDate *)selectedDate {
    if (![_selectedDate isEqualToDate:selectedDate] || ![selectedDate isEqualToDate:[self currentDate]]) {
        _selectedDate = selectedDate ? [selectedDate copy] : selectedDate;
        [self updateComponentsWithDate:selectedDate];
    }
}

- (void)setMinimumDate:(NSDate *)minimumDate {
    if (_minimumDate != minimumDate) {
        _minimumDate = minimumDate ? [minimumDate copy] : nil;
        AssertMaxAndMinDate(self.maximumDate, minimumDate);
        self.selectedDate = [self adjustedMaxAndMinDateForDate:self.selectedDate];
    }
}

- (void)setMaximumDate:(NSDate *)maximumDate {
    if (_maximumDate != maximumDate) {
        _maximumDate = maximumDate ? [maximumDate copy] : nil;
        AssertMaxAndMinDate(maximumDate, self.minimumDate);
        self.selectedDate = [self adjustedMaxAndMinDateForDate:self.selectedDate];
    }
}

- (void)setDateFormatter:(NSString *)dateFormatter {
    if (![_dateFormatter isEqualToString:dateFormatter]) {
        _dateFormatter = dateFormatter ? [dateFormatter copy] : nil;
        
        [self.dateFormatComponents removeAllObjects];   // 移除旧数据
        
        NSMutableArray *normalFormatArray = [NSMutableArray array];
        NSArray <NSString *>*formatterComs = [_dateFormatter componentsSeparatedByString:@"/"];
        
        for (NSString *com in formatterComs) {
            
            HWDateFormatComponent *formatCom = [[HWDateFormatComponent alloc] init];
            formatCom.dateFormat = com;
            formatCom.index = [formatterComs indexOfObject:com];
            
            // 有效的 component
            if (formatCom.normalFormat.length) {
                [self.dateFormatComponents addObject:formatCom];
                [normalFormatArray addObject:formatCom.normalFormat];
            }
        }
        
        self.normalFormat = [normalFormatArray componentsJoinedByString:@"/"];
        [self.pickerView reloadAllComponents];
        
        [self updateComponentsWithDate:self.selectedDate];
    }
}

#pragma mark - adjustment

- (NSDate *)adjustedMaxAndMinDateForDate:(NSDate *)date {
    if (self.minimumDate) {
        if ([date timeIntervalSince1970] < [self.minimumDate timeIntervalSince1970]) {
            return self.minimumDate;
        }
    }
    
    if (self.maximumDate) {
        if ([date timeIntervalSince1970] > [self.maximumDate timeIntervalSince1970]) {
            return self.maximumDate;
        }
    }
    
    return date;
}

#pragma mark - UIPickerViewDelegate

// width
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return (pickerView.frame.size.width - self.dateFormatComponents.count * 5.0) / self.dateFormatComponents.count;
}

// height
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickerView:rowHeightForComponent:)]) {
        return [self.delegate pickerView:self rowHeightForComponent:component];
    } else {
        return self.rowHeight;
    }
}

// item view
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {
    UILabel *label = [self componentLabelWithString:[self titleForRow:row forComponent:component]];
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickerView:textAttributeForRow:forComponent:)]) {
        label.attributedText = [[NSAttributedString alloc] initWithString:label.text attributes:[self.delegate pickerView:self textAttributeForRow:row forComponent:component]];
    } else {
        label.textColor = self.textColor;
        label.font = self.textFont;
    }
    return label;
}

// select call back
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSInteger unit = self.dateFormatComponents[component].unit;
    if (unit == NSCalendarUnitYear) {
        _year = [self valueStringForRow:row forComponent:component].integerValue;
    } else if (unit == NSCalendarUnitMonth) {
        _month = [self valueStringForRow:row forComponent:component].integerValue;
    } else if (unit == NSCalendarUnitDay) {
        _day = [self valueStringForRow:row forComponent:component].integerValue;
    } else if (unit == NSCalendarUnitHour) {
        _hour = [self valueStringForRow:row forComponent:component].integerValue;
    } else if (unit == NSCalendarUnitMinute) {
        _minute = [self valueStringForRow:row forComponent:component].integerValue;
    } else if (unit == NSCalendarUnitSecond) {
        _second = [self valueStringForRow:row forComponent:component].integerValue;
    }
    
    // adjust max day
    NSUInteger maxDays = [self maxDaysForDate:[[NSString stringWithFormat:@"%lu/%.2ld/10",
                                                (unsigned long)self.year,
                                                (unsigned long)self.month]
                                               dateWithFormat:@"YYYY/MM/dd" timeZone:self.calendar.timeZone]];
    self.day = MIN(self.day, maxDays);
    
    // adjust date range
    self.selectedDate = [self adjustedMaxAndMinDateForDate:[self currentDate]];
    
    // callback delegate
    [self callbackDelegate];
}

#pragma mark - UIPickerViewDataSource

// number Of components
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.dateFormatComponents.count;
}

// number Of rows
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.dateFormatComponents && self.dateFormatComponents.count > component) {
        HWDateFormatComponent *com = self.dateFormatComponents[component];
        NSDictionary <NSNumber *,NSNumber *>*numberDic = @{@(NSCalendarUnitYear):@(kMaxYearCount),
                                                           @(NSCalendarUnitMonth):@(12),
                                                           @(NSCalendarUnitDay):@(31),
                                                           @(NSCalendarUnitHour):@([com.normalFormat isEqualToString:@"HH"] ? 24 : 12),
                                                           @(NSCalendarUnitMinute):@(60),
                                                           @(NSCalendarUnitSecond):@(60),
                                                           };
        if (numberDic[@(com.unit)]) {
            return [numberDic[@(com.unit)] integerValue];
        }
    }
    return 0;
}

#pragma mark - private methods

- (NSUInteger)maxDaysForDate:(NSDate *)date {
    return [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
}

- (void)updateComponentsWithDate:(NSDate *)date {
    if (date) {
        self.year = [date stringWithFormat:@"yyyy"].integerValue;
        self.month = [date stringWithFormat:@"MM"].integerValue;
        self.day = [date stringWithFormat:@"dd"].integerValue;
        self.hour = [date stringWithFormat:@"HH"].integerValue;
        self.minute = [date stringWithFormat:@"mm"].integerValue;
        self.second = [date stringWithFormat:@"ss"].integerValue;
    } else {
        self.year = 0;
        self.month = 0;
        self.day = 0;
        self.hour = 0;
        self.minute = 0;
        self.second = 0;
    }
}

- (NSDate *)currentDate {
    NSString *selectedString = [NSString stringWithFormat:@"%lu/%.2ld/%.2ld/%.2ld/%.2ld/%.2ld",
                                (unsigned long)self.year,
                                (unsigned long)self.month,
                                (unsigned long)self.day,
                                (unsigned long)self.hour,
                                (unsigned long)self.minute,
                                (unsigned long)self.second];
    return [selectedString dateWithFormat:@"YYYY/MM/dd/HH/mm/ss" timeZone:self.calendar.timeZone];
}

- (BOOL)indexOfComponentType:(NSCalendarUnit)componentType index:(NSUInteger *)index{
    for (HWDateFormatComponent*com in _dateFormatComponents) {
        if (com.unit == componentType) {
            if (index != NULL) {
                *index = [_dateFormatComponents indexOfObject:com];
            }
            return YES;
        }
    }
    return NO;
}

- (void)setComponentValue:(NSUInteger)value forComponentType:(NSCalendarUnit)type {
    NSUInteger index;
    if ([self indexOfComponentType:type index:&index]) {
        HWDateFormatComponent *com = self.dateFormatComponents[index];
        NSDictionary <NSNumber *,NSNumber *>*rangMap = @{@(NSCalendarUnitYear):@(kMaxYearCount),
                                                         @(NSCalendarUnitMonth):@(12),
                                                         @(NSCalendarUnitDay):@(31),
                                                         @(NSCalendarUnitHour):@([com.normalFormat isEqualToString:@"HH"] ? 24 : 12),
                                                         @(NSCalendarUnitMinute):@(60),
                                                         @(NSCalendarUnitSecond):@(60),
                                                         };
        
        NSInteger valueAtFirstRow = [self valueStringForRow:0 forComponent:index].integerValue;
        NSUInteger row = 0;
        
        if (NSCalendarUnitYear == type) {
            row = value;
        } else {
            row = (value - valueAtFirstRow) % [rangMap[@(type)] integerValue];
        }
        
        if ([self.pickerView numberOfComponents] > index && [self.pickerView numberOfRowsInComponent:index] > row) {
            if ([self.pickerView selectedRowInComponent:index] != row) {
                [self.pickerView selectRow:row inComponent:index animated:NO];
            }
        }
    }
}

- (NSString *)titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *dateString = [self.selectedDate stringWithFormat:self.dateFormatter];
    NSString *title =[dateString componentsSeparatedByString:@"/"][self.dateFormatComponents[component].index];
    title = [title stringByReplacingOccurrencesOfString:title.numberStrings.firstObject withString:[self valueStringForRow:row forComponent:component]];
    return title;
}

- (NSString *)valueStringForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSInteger unit = self.dateFormatComponents[component].unit;
    if (unit == NSCalendarUnitYear) {
        return [NSString stringWithFormat:@"%.4ld",(long)row];
    } else if (unit == NSCalendarUnitMonth || unit == NSCalendarUnitDay){
        return [NSString stringWithFormat:@"%.2ld",(long)row + 1];
    } else {
        return [NSString stringWithFormat:@"%.2ld",(long)row];
    }
}

- (UILabel *)componentLabelWithString:(NSString *)string {
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = string;
    return label;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSString *layoutSubviewsKey = [NSString stringWithFormat:@"%@", [NSValue valueWithCGSize:self.frame.size]];
    if ([self.layoutSubviewsKey isEqualToString:layoutSubviewsKey]) return;
    
    self.layoutSubviewsKey = layoutSubviewsKey;
    self.pickerView.frame = self.bounds;
}

- (void)addObserveForKeyPaths:(NSArray <NSString *>*)keyPaths {
    __weak typeof(self) ws = self;
    for (NSString *keyPath in keyPaths) {
        [self addObserver:ws forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:HWDatePickerObserverContext];
    }
}

- (void)removeObserveForKeyPaths:(NSArray <NSString *>*)keyPaths {
    for (NSString *keyPath in keyPaths) {
        [self removeObserver:self forKeyPath:keyPath context:HWDatePickerObserverContext];
    }
}

- (void)dealloc {
    [self removeObserveForKeyPaths:@[@"year",@"month",@"day",@"hour",@"minute",@"second"]];
}

@end
