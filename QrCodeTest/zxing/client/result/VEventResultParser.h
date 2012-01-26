#import "Result.h"

/**
 * Partially implements the iCalendar format's "VEVENT" format for specifying a
 * calendar event. See RFC 2445. This supports SUMMARY, LOCATION, GEO, DTSTART and DTEND fields.
 * 
 * @author Sean Owen
 */

@interface VEventResultParser : ResultParser {
}

+ (CalendarParsedResult *) parse:(Result *)result;
@end
