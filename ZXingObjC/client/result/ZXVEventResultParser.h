#import "ZXResultParser.h"

/**
 * Partially implements the iCalendar format's "VEVENT" format for specifying a
 * calendar event. See RFC 2445. This supports SUMMARY, LOCATION, GEO, DTSTART and DTEND fields.
 */

@class ZXCalendarParsedResult, ZXResult;

@interface ZXVEventResultParser : ZXResultParser

+ (ZXCalendarParsedResult *)parse:(ZXResult *)result;

@end
