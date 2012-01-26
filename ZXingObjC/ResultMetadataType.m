#import "ResultMetadataType.h"

NSMutableDictionary * const VALUES = [[[NSMutableDictionary alloc] init] autorelease];

/**
 * Unspecified, application-specific metadata. Maps to an unspecified {@link Object}.
 */
ResultMetadataType * const OTHER = [[[ResultMetadataType alloc] init:@"OTHER"] autorelease];

/**
 * Denotes the likely approximate orientation of the barcode in the image. This value
 * is given as degrees rotated clockwise from the normal, upright orientation.
 * For example a 1D barcode which was found by reading top-to-bottom would be
 * said to have orientation "90". This key maps to an {@link Integer} whose
 * value is in the range [0,360).
 */
ResultMetadataType * const ORIENTATION = [[[ResultMetadataType alloc] init:@"ORIENTATION"] autorelease];

/**
 * <p>2D barcode formats typically encode text, but allow for a sort of 'byte mode'
 * which is sometimes used to encode binary data. While {@link Result} makes available
 * the complete raw bytes in the barcode for these formats, it does not offer the bytes
 * from the byte segments alone.</p>
 * 
 * <p>This maps to a {@link java.util.Vector} of byte arrays corresponding to the
 * raw bytes in the byte segments in the barcode, in order.</p>
 */
ResultMetadataType * const BYTE_SEGMENTS = [[[ResultMetadataType alloc] init:@"BYTE_SEGMENTS"] autorelease];

/**
 * Error correction level used, if applicable. The value type depends on the
 * format, but is typically a String.
 */
ResultMetadataType * const ERROR_CORRECTION_LEVEL = [[[ResultMetadataType alloc] init:@"ERROR_CORRECTION_LEVEL"] autorelease];

/**
 * For some periodicals, indicates the issue number as an {@link Integer}.
 */
ResultMetadataType * const ISSUE_NUMBER = [[[ResultMetadataType alloc] init:@"ISSUE_NUMBER"] autorelease];

/**
 * For some products, indicates the suggested retail price in the barcode as a
 * formatted {@link String}.
 */
ResultMetadataType * const SUGGESTED_PRICE = [[[ResultMetadataType alloc] init:@"SUGGESTED_PRICE"] autorelease];

/**
 * For some products, the possible country of manufacture as a {@link String} denoting the
 * ISO country code. Some map to multiple possible countries, like "US/CA".
 */
ResultMetadataType * const POSSIBLE_COUNTRY = [[[ResultMetadataType alloc] init:@"POSSIBLE_COUNTRY"] autorelease];

@implementation ResultMetadataType

@synthesize name;

- (id) initWithName:(NSString *)name {
  if (self = [super init]) {
    name = name;
    [VALUES setObject:name param1:self];
  }
  return self;
}

- (NSString *) description {
  return name;
}

+ (ResultMetadataType *) valueOf:(NSString *)name {
  if (name == nil || [name length] == 0) {
    @throw [[[IllegalArgumentException alloc] init] autorelease];
  }
  ResultMetadataType * format = (ResultMetadataType *)[VALUES objectForKey:name];
  if (format == nil) {
    @throw [[[IllegalArgumentException alloc] init] autorelease];
  }
  return format;
}

- (void) dealloc {
  [name release];
  [super dealloc];
}

@end
