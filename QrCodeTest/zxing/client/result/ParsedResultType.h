
/**
 * Represents the type of data encoded by a barcode -- from plain text, to a
 * URI, to an e-mail address, etc.
 * 
 * @author Sean Owen
 */

extern ParsedResultType * const ADDRESSBOOK;
extern ParsedResultType * const EMAIL_ADDRESS;
extern ParsedResultType * const PRODUCT;
extern ParsedResultType * const URI;
extern ParsedResultType * const TEXT;
extern ParsedResultType * const ANDROID_INTENT;
extern ParsedResultType * const GEO;
extern ParsedResultType * const TEL;
extern ParsedResultType * const SMS;
extern ParsedResultType * const CALENDAR;
extern ParsedResultType * const WIFI;
extern ParsedResultType * const NDEF_SMART_POSTER;
extern ParsedResultType * const MOBILETAG_RICH_WEB;
extern ParsedResultType * const ISBN;

@interface ParsedResultType : NSObject {
  NSString * name;
}

- (NSString *) description;
@end
