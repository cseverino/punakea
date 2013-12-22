// Copyright (c) 2006-2013 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NNSimpleQueryFilter.h"


@implementation NNSimpleQueryFilter

#pragma mark init
- (id)initWithAttribute:(NSString*)anAttribute value:(NSString*)aValue
{
	if (self = [super init])
	{
		[self setAttribute:anAttribute];
		[self setValue:aValue];
		valueUsesWildcard = NO;
		options = @"";
	}
	return self;
}

- (void)dealloc
{
	[value release];
	[attribute release];
	[super dealloc];
}

+ (NNSimpleQueryFilter*)simpleQueryFilterWithAttribute:(NSString*)anAttribute value:(NSString*)aValue
{
	NNSimpleQueryFilter *filter = [[NNSimpleQueryFilter alloc] initWithAttribute:anAttribute
																		   value:aValue];
	return [filter autorelease];
}

#pragma mark accessors
- (NSString*)attribute
{
	return attribute;
}

- (void)setAttribute:(NSString*)anAttribute
{
	[anAttribute retain];
	[attribute release];
	attribute = anAttribute;
}

- (NSString*)value
{
	return value;
}

- (void)setValue:(NSString*)aValue
{
	[aValue retain];
	[value release];
	value = aValue;
}

- (BOOL)valueUsesWildcard
{
	return valueUsesWildcard;
}

- (void)setValueUsesWildcard:(BOOL)flag
{
	valueUsesWildcard = flag;
}

- (NSString *)options
{
	return options;
}

- (void)setOptions:(NSString *)theOptions
{
	[options release];
	options = [theOptions retain];
}


#pragma mark abstract implemented
- (NSString*)filterPredicateString
{
	NSString *comparatorString = valueUsesWildcard ? @"==" : @"LIKE";
	NSString *formattedFilter = [NSString stringWithFormat:@"(%@ %@ \"%@\"%@)",attribute,comparatorString,value, options];
	return formattedFilter;
}

@end
