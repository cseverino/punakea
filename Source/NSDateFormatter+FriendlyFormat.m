//
//  NSDateFormatter+FriendlyFormat.m
//  punakea
//
//  Created by Daniel on 10/23/06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "NSDateFormatter+FriendlyFormat.h"


@implementation NSDateFormatter (FriendlyFormat)

// TODO: Localize!

- (NSString *)friendlyStringFromDate:(NSDate *)date
{
	if(!date) return NSLocalizedStringFromTable(@"NO_DATE",@"Global",@"");
	
	// Save current styles
	NSDateFormatterStyle dateStyle = [self dateStyle];
	NSDateFormatterStyle timeStyle = [self timeStyle];
	
	NSCalendarDate *cdate = [date dateWithCalendarFormat:nil timeZone:nil];
	NSInteger today = [[NSCalendarDate calendarDate] dayOfCommonEra];
	NSInteger dateDay = [cdate dayOfCommonEra];
	
	NSString *value = nil;
	
	if(dateDay == today)		value = NSLocalizedStringFromTable(@"TODAY",@"Global",@"");
	if(dateDay == (today - 1))	value = NSLocalizedStringFromTable(@"YESTERDAY",@"Global",@"");
	
	if(value)
	{
		// Append time to our friendly string
		
		[self setDateStyle:NSDateFormatterNoStyle];
		[self setTimeStyle:NSDateFormatterShortStyle];
		
		value = [value stringByAppendingString:@" "];
		value = [value stringByAppendingString:[self stringFromDate:date]];
	}
	else if ([date isEqualToDate:[NSDate dateWithTimeIntervalSince1970:0]])
	{
		// date was created by passing 0 - display never
		  value = NSLocalizedStringFromTable(@"NEVER",@"Global",@"");
	}
	else
	{
		// Show only month and year if this is an older date		
		if([date timeIntervalSinceNow] > [[NSNumber numberWithInteger:-60*60*24*40] doubleValue])
		{
			[self setTimeStyle:NSDateFormatterShortStyle];
		} else {
			[self setDateFormat:@"MMMM yyyy"];
		}
		
		value = [self stringFromDate:date];
	}
	
	// Restore styles
	[self setDateStyle:dateStyle];
	[self setTimeStyle:timeStyle];

	return value;
}

- (NSString *)saveStringFromDate:(NSDate *)date
{
	NSString *s = [self stringFromDate:date];
	
	return s ? s : NSLocalizedStringFromTable(@"NO_DATE",@"Global",@"");
}

@end
