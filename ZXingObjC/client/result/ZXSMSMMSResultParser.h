#import "ZXResultParser.h"

/**
 * Parses an "sms:" URI result, which specifies a number to SMS.
 * See http://tools.ietf.org/html/rfc5724 on this.
 * 
 * This class supports "via" syntax for numbers, which is not part of the spec.
 * For example "+12125551212;via=+12124440101" may appear as a number.
 * It also supports a "subject" query parameter, which is not mentioned in the spec.
 * These are included since they were mentioned in earlier IETF drafts and might be
 * used.
 * 
 * This actually also parses URIs starting with "mms:" and treats them all the same way,
 * and effectively converts them to an "sms:" URI for purposes of forwarding to the platform.
 */

@class ZXResult, ZXSMSParsedResult;

@interface ZXSMSMMSResultParser : ZXResultParser

+ (ZXSMSParsedResult *)parse:(ZXResult *)result;

@end
