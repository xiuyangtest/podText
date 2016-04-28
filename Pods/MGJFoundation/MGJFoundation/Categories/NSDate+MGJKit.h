/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook 3.x and beyond
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

#define MGJ_D_MINUTE	60
#define MGJ_D_HOUR		3600
#define MGJ_D_DAY		86400
#define MGJ_D_WEEK		604800
#define MGJ_D_YEAR		31556926

@interface NSDate (MGJKit)

// Relative dates from the current date
+ (NSDate *) mgj_dateTomorrow;
+ (NSDate *) mgj_dateYesterday;
+ (NSDate *) mgj_dateWithDaysFromNow: (NSUInteger) days;
+ (NSDate *) mgj_dateWithDaysBeforeNow: (NSUInteger) days;
+ (NSDate *) mgj_dateWithHoursFromNow: (NSUInteger) dHours;
+ (NSDate *) mgj_dateWithHoursBeforeNow: (NSUInteger) dHours;
+ (NSDate *) mgj_dateWithMinutesFromNow: (NSUInteger) dMinutes;
+ (NSDate *) mgj_dateWithMinutesBeforeNow: (NSUInteger) dMinutes;

// Comparing dates
- (BOOL) mgj_isEqualToDateIgnoringTime: (NSDate *) aDate;
- (BOOL) mgj_isToday;
- (BOOL) mgj_isTomorrow;
- (BOOL) mgj_isYesterday;
- (BOOL) mgj_isSameWeekAsDate: (NSDate *) aDate;
- (BOOL) mgj_isThisWeek;
- (BOOL) mgj_isNextWeek;
- (BOOL) mgj_isLastWeek;
- (BOOL) mgj_isSameYearAsDate: (NSDate *) aDate;
- (BOOL) mgj_isThisYear;
- (BOOL) mgj_isNextYear;
- (BOOL) mgj_isLastYear;
- (BOOL) mgj_isEarlierThanDate: (NSDate *) aDate;
- (BOOL) mgj_isLaterThanDate: (NSDate *) aDate;

// Adjusting dates
- (NSDate *) mgj_dateByAddingDays: (NSUInteger) dDays;
- (NSDate *) mgj_dateBySubtractingDays: (NSUInteger) dDays;
- (NSDate *) mgj_dateByAddingHours: (NSUInteger) dHours;
- (NSDate *) mgj_dateBySubtractingHours: (NSUInteger) dHours;
- (NSDate *) mgj_dateByAddingMinutes: (NSUInteger) dMinutes;
- (NSDate *) mgj_dateBySubtractingMinutes: (NSUInteger) dMinutes;
- (NSDate *) mgj_dateAtStartOfDay;

// Retrieving intervals
- (NSInteger) minutesAfterDate: (NSDate *) aDate;
- (NSInteger) minutesBeforeDate: (NSDate *) aDate;
- (NSInteger) hoursAfterDate: (NSDate *) aDate;
- (NSInteger) hoursBeforeDate: (NSDate *) aDate;
- (NSInteger) daysAfterDate: (NSDate *) aDate;
- (NSInteger) daysBeforeDate: (NSDate *) aDate;

// Decomposing dates
@property (readonly) NSInteger mgj_nearestHour;
@property (readonly) NSInteger mgj_hour;
@property (readonly) NSInteger mgj_minute;
@property (readonly) NSInteger mgj_seconds;
@property (readonly) NSInteger mgj_day;
@property (readonly) NSInteger mgj_month;
@property (readonly) NSInteger mgj_week;
@property (readonly) NSInteger mgj_weekday;
@property (readonly) NSInteger mgj_nthWeekday; // e.g. 2nd Tuesday of the month == 2
@property (readonly) NSInteger mgj_year;
@end