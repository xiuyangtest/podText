/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook 3.x and beyond
 BSD License, Use at your own risk
 */

/*
 #import <humor.h> : Not planning to implement: dateByAskingBoyOut and dateByGettingBabysitter
 ----
 General Thanks: sstreza, Scott Lawrence, Kevin Ballard, NoOneButMe, Avi`, August Joki. Emanuele Vulcano, jcromartiej
 */

#import "NSDate+MGJKit.h"
#import "MGJMacros.h"

#if ( defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED < 80000 )

#define MGJ_CALENDAR_UNIT_YEAR NSYearCalendarUnit
#define MGJ_CALENDAR_UNIT_MONTH NSMonthCalendarUnit
#define MGJ_CALENDAR_UNIT_DAY NSDayCalendarUnit
#define MGJ_CALENDAR_UNIT_WEEK NSWeekCalendarUnit
#define MGJ_CALENDAR_UNIT_HOUR NSHourCalendarUnit
#define MGJ_CALENDAR_UNIT_MINUTE NSMinuteCalendarUnit
#define MGJ_CALENDAR_UNIT_SECOND NSSecondCalendarUnit
#define MGJ_CALENDAR_UNIT_WEEKDAY NSWeekdayCalendarUnit
#define MGJ_CALENDAR_UNIT_WEEKDAY_ORDINAL NSWeekdayOrdinalCalendarUnit

#else

#define MGJ_CALENDAR_UNIT_YEAR NSCalendarUnitYear
#define MGJ_CALENDAR_UNIT_MONTH NSCalendarUnitMonth
#define MGJ_CALENDAR_UNIT_DAY NSCalendarUnitDay
#define MGJ_CALENDAR_UNIT_WEEK NSCalendarUnitWeekOfYear
#define MGJ_CALENDAR_UNIT_HOUR NSCalendarUnitHour
#define MGJ_CALENDAR_UNIT_MINUTE NSCalendarUnitMinute
#define MGJ_CALENDAR_UNIT_SECOND NSCalendarUnitSecond
#define MGJ_CALENDAR_UNIT_WEEKDAY NSCalendarUnitWeekday
#define MGJ_CALENDAR_UNIT_WEEKDAY_ORDINAL NSCalendarUnitWeekdayOrdinal

#endif

#define MGJ_DATE_COMPONENTS (MGJ_CALENDAR_UNIT_YEAR | MGJ_CALENDAR_UNIT_MONTH | MGJ_CALENDAR_UNIT_DAY | MGJ_CALENDAR_UNIT_WEEK | MGJ_CALENDAR_UNIT_HOUR | MGJ_CALENDAR_UNIT_MINUTE | MGJ_CALENDAR_UNIT_SECOND | MGJ_CALENDAR_UNIT_WEEKDAY | MGJ_CALENDAR_UNIT_WEEKDAY_ORDINAL)
#define MGJ_CURRENT_CALENDAR [NSCalendar currentCalendar]

@implementation NSDate (Utilities)

#pragma mark Relative Dates

+ (NSDate *) mgj_dateWithDaysFromNow: (NSUInteger) days
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + MGJ_D_DAY * days;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) mgj_dateWithDaysBeforeNow: (NSUInteger) days
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - MGJ_D_DAY * days;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) mgj_dateTomorrow
{
    return [NSDate mgj_dateWithDaysFromNow:1];
}

+ (NSDate *) mgj_dateYesterday
{
    return [NSDate mgj_dateWithDaysBeforeNow:1];
}

+ (NSDate *) mgj_dateWithHoursFromNow: (NSUInteger) dHours
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + MGJ_D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) mgj_dateWithHoursBeforeNow: (NSUInteger) dHours
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - MGJ_D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) mgj_dateWithMinutesFromNow: (NSUInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + MGJ_D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) mgj_dateWithMinutesBeforeNow: (NSUInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - MGJ_D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

#pragma mark Comparing Dates

- (BOOL) mgj_isEqualToDateIgnoringTime: (NSDate *) aDate
{
    NSDateComponents *components1 = [MGJ_CURRENT_CALENDAR components:MGJ_DATE_COMPONENTS fromDate:self];
    NSDateComponents *components2 = [MGJ_CURRENT_CALENDAR components:MGJ_DATE_COMPONENTS fromDate:aDate];
    return (([components1 year] == [components2 year]) &&
            ([components1 month] == [components2 month]) &&
            ([components1 day] == [components2 day]));
}

- (BOOL) mgj_isToday
{
    return [self mgj_isEqualToDateIgnoringTime:[NSDate date]];
}

- (BOOL) mgj_isTomorrow
{
    return [self mgj_isEqualToDateIgnoringTime:[NSDate mgj_dateTomorrow]];
}

- (BOOL) mgj_isYesterday
{
    return [self mgj_isEqualToDateIgnoringTime:[NSDate mgj_dateYesterday]];
}

// This hard codes the assumption that a week is 7 days
- (BOOL) mgj_isSameWeekAsDate: (NSDate *) aDate
{
    NSDateComponents *components1 = [MGJ_CURRENT_CALENDAR components:MGJ_DATE_COMPONENTS fromDate:self];
    NSDateComponents *components2 = [MGJ_CURRENT_CALENDAR components:MGJ_DATE_COMPONENTS fromDate:aDate];
    
    // Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
    if ([components1 weekOfYear] != [components2 weekOfYear]) return NO;
    
    // Must have a time interval under 1 week. Thanks @aclark
    return (fabs([self timeIntervalSinceDate:aDate]) < MGJ_D_WEEK);
}

- (BOOL) mgj_isThisWeek
{
    return [self mgj_isSameWeekAsDate:[NSDate date]];
}

- (BOOL) mgj_isNextWeek
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + MGJ_D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self mgj_isSameYearAsDate:newDate];
}

- (BOOL) mgj_isLastWeek
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - MGJ_D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self mgj_isSameYearAsDate:newDate];
}

- (BOOL) mgj_isSameYearAsDate: (NSDate *) aDate
{
    NSDateComponents *components1 = [MGJ_CURRENT_CALENDAR components:MGJ_CALENDAR_UNIT_YEAR fromDate:self];
    NSDateComponents *components2 = [MGJ_CURRENT_CALENDAR components:MGJ_CALENDAR_UNIT_YEAR fromDate:aDate];
    return ([components1 year] == [components2 year]);
}

- (BOOL) mgj_isThisYear
{
    return [self mgj_isSameWeekAsDate:[NSDate date]];
}

- (BOOL) mgj_isNextYear
{
    NSDateComponents *components1 = [MGJ_CURRENT_CALENDAR components:MGJ_CALENDAR_UNIT_YEAR fromDate:self];
    NSDateComponents *components2 = [MGJ_CURRENT_CALENDAR components:MGJ_CALENDAR_UNIT_YEAR fromDate:[NSDate date]];
    
    return ([components1 year] == ([components2 year] + 1));
}

- (BOOL) mgj_isLastYear
{
    NSDateComponents *components1 = [MGJ_CURRENT_CALENDAR components:MGJ_CALENDAR_UNIT_YEAR fromDate:self];
    NSDateComponents *components2 = [MGJ_CURRENT_CALENDAR components:MGJ_CALENDAR_UNIT_YEAR fromDate:[NSDate date]];
    
    return ([components1 year] == ([components2 year] - 1));
}

- (BOOL) mgj_isEarlierThanDate: (NSDate *) aDate
{
    return ([self earlierDate:aDate] == self);
}

- (BOOL) mgj_isLaterThanDate: (NSDate *) aDate
{
    return ([self laterDate:aDate] == self);
}


#pragma mark Adjusting Dates

- (NSDate *) mgj_dateByAddingDays: (NSUInteger) dDays
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + MGJ_D_DAY * dDays;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) mgj_dateBySubtractingDays: (NSUInteger) dDays
{
    return [self mgj_dateByAddingDays: (dDays * -1)];
}

- (NSDate *) mgj_dateByAddingHours: (NSUInteger) dHours
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + MGJ_D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) mgj_dateBySubtractingHours: (NSUInteger) dHours
{
    return [self mgj_dateByAddingHours: (dHours * -1)];
}

- (NSDate *) mgj_dateByAddingMinutes: (NSUInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + MGJ_D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) mgj_dateBySubtractingMinutes: (NSUInteger) dMinutes
{
    return [self mgj_dateByAddingMinutes: (dMinutes * -1)];
}

- (NSDate *) mgj_dateAtStartOfDay
{
    NSDateComponents *components = [MGJ_CURRENT_CALENDAR components:MGJ_DATE_COMPONENTS fromDate:self];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    return [MGJ_CURRENT_CALENDAR dateFromComponents:components];
}

- (NSDateComponents *) mgj_componentsWithOffsetFromDate: (NSDate *) aDate
{
    NSDateComponents *dTime = [MGJ_CURRENT_CALENDAR components:MGJ_DATE_COMPONENTS fromDate:aDate toDate:self options:0];
    return dTime;
}

#pragma mark Retrieving Intervals

- (NSInteger) mgj_minutesAfterDate: (NSDate *) aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / MGJ_D_MINUTE);
}

- (NSInteger) mgj_minutesBeforeDate: (NSDate *) aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / MGJ_D_MINUTE);
}

- (NSInteger) mgj_hoursAfterDate: (NSDate *) aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / MGJ_D_HOUR);
}

- (NSInteger) mgj_hoursBeforeDate: (NSDate *) aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / MGJ_D_HOUR);
}

- (NSInteger) mgj_daysAfterDate: (NSDate *) aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / MGJ_D_DAY);
}

- (NSInteger) mgj_daysBeforeDate: (NSDate *) aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / MGJ_D_DAY);
}

#pragma mark Decomposing Dates

- (NSInteger) mgj_nearestHour
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + MGJ_D_MINUTE * 30;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    NSDateComponents *components = [MGJ_CURRENT_CALENDAR components:MGJ_CALENDAR_UNIT_HOUR fromDate:newDate];
    return [components hour];
}

- (NSInteger) mgj_hour
{
    NSDateComponents *components = [MGJ_CURRENT_CALENDAR components:MGJ_DATE_COMPONENTS fromDate:self];
    return [components hour];
}

- (NSInteger) mgj_minute
{
    NSDateComponents *components = [MGJ_CURRENT_CALENDAR components:MGJ_DATE_COMPONENTS fromDate:self];
    return [components minute];
}

- (NSInteger) mgj_seconds
{
    NSDateComponents *components = [MGJ_CURRENT_CALENDAR components:MGJ_DATE_COMPONENTS fromDate:self];
    return [components second];
}

- (NSInteger) mgj_day
{
    NSDateComponents *components = [MGJ_CURRENT_CALENDAR components:MGJ_DATE_COMPONENTS fromDate:self];
    return [components day];
}

- (NSInteger) mgj_month
{
    NSDateComponents *components = [MGJ_CURRENT_CALENDAR components:MGJ_DATE_COMPONENTS fromDate:self];
    return [components month];
}

- (NSInteger) mgj_week
{
    NSDateComponents *components = [MGJ_CURRENT_CALENDAR components:MGJ_DATE_COMPONENTS fromDate:self];
    return [components weekOfYear];
}

- (NSInteger) mgj_weekday
{
    NSDateComponents *components = [MGJ_CURRENT_CALENDAR components:MGJ_DATE_COMPONENTS fromDate:self];
    return [components weekday];
}

- (NSInteger) mgj_nthWeekday // e.g. 2nd Tuesday of the month is 2
{
    NSDateComponents *components = [MGJ_CURRENT_CALENDAR components:MGJ_DATE_COMPONENTS fromDate:self];
    return [components weekdayOrdinal];
}
- (NSInteger) mgj_year
{
    NSDateComponents *components = [MGJ_CURRENT_CALENDAR components:MGJ_DATE_COMPONENTS fromDate:self];
    return [components year];
}
@end
