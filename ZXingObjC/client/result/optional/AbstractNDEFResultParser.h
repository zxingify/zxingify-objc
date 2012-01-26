#import "ResultParser.h"
#import "UnsupportedEncodingException.h"

/**
 * <p>Superclass for classes encapsulating results in the NDEF format.
 * See <a href="http://www.nfc-forum.org/specs/">http://www.nfc-forum.org/specs/</a>.</p>
 * 
 * <p>This code supports a limited subset of NDEF messages, ones that are plausibly
 * useful in 2D barcode formats. This generally includes 1-record messages, no chunking,
 * "short record" syntax, no ID field.</p>
 * 
 * @author Sean Owen
 */

@interface AbstractNDEFResultParser : ResultParser {
}

+ (NSString *) bytesToString:(NSArray *)bytes offset:(int)offset length:(int)length encoding:(NSString *)encoding;
@end
