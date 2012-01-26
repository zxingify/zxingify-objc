#import "BarcodeFormat.h"

NSMutableDictionary * const VALUES = [[[NSMutableDictionary alloc] init] autorelease];

/**
 * Aztec 2D barcode format.
 */
BarcodeFormat * const AZTEC = [[[BarcodeFormat alloc] init:@"AZTEC"] autorelease];

/**
 * CODABAR 1D format.
 */
BarcodeFormat * const CODABAR = [[[BarcodeFormat alloc] init:@"CODABAR"] autorelease];

/**
 * Code 39 1D format.
 */
BarcodeFormat * const CODE_39 = [[[BarcodeFormat alloc] init:@"CODE_39"] autorelease];

/**
 * Code 93 1D format.
 */
BarcodeFormat * const CODE_93 = [[[BarcodeFormat alloc] init:@"CODE_93"] autorelease];

/**
 * Code 128 1D format.
 */
BarcodeFormat * const CODE_128 = [[[BarcodeFormat alloc] init:@"CODE_128"] autorelease];

/**
 * Data Matrix 2D barcode format.
 */
BarcodeFormat * const DATA_MATRIX = [[[BarcodeFormat alloc] init:@"DATA_MATRIX"] autorelease];

/**
 * EAN-8 1D format.
 */
BarcodeFormat * const EAN_8 = [[[BarcodeFormat alloc] init:@"EAN_8"] autorelease];

/**
 * EAN-13 1D format.
 */
BarcodeFormat * const EAN_13 = [[[BarcodeFormat alloc] init:@"EAN_13"] autorelease];

/**
 * ITF (Interleaved Two of Five) 1D format.
 */
BarcodeFormat * const ITF = [[[BarcodeFormat alloc] init:@"ITF"] autorelease];

/**
 * PDF417 format.
 */
BarcodeFormat * const PDF_417 = [[[BarcodeFormat alloc] init:@"PDF_417"] autorelease];

/**
 * QR Code 2D barcode format.
 */
BarcodeFormat * const QR_CODE = [[[BarcodeFormat alloc] init:@"QR_CODE"] autorelease];

/**
 * RSS 14
 */
BarcodeFormat * const RSS_14 = [[[BarcodeFormat alloc] init:@"RSS_14"] autorelease];

/**
 * RSS EXPANDED
 */
BarcodeFormat * const RSS_EXPANDED = [[[BarcodeFormat alloc] init:@"RSS_EXPANDED"] autorelease];

/**
 * UPC-A 1D format.
 */
BarcodeFormat * const UPC_A = [[[BarcodeFormat alloc] init:@"UPC_A"] autorelease];

/**
 * UPC-E 1D format.
 */
BarcodeFormat * const UPC_E = [[[BarcodeFormat alloc] init:@"UPC_E"] autorelease];

/**
 * UPC/EAN extension format. Not a stand-alone format.
 */
BarcodeFormat * const UPC_EAN_EXTENSION = [[[BarcodeFormat alloc] init:@"UPC_EAN_EXTENSION"] autorelease];

@implementation BarcodeFormat

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

+ (BarcodeFormat *) valueOf:(NSString *)name {
  if (name == nil || [name length] == 0) {
    @throw [[[IllegalArgumentException alloc] init] autorelease];
  }
  BarcodeFormat * format = (BarcodeFormat *)[VALUES objectForKey:name];
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
