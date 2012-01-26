#import "BarcodeFormat.h"

@interface BarcodeFormat () {
  NSString *_name;
}

@property (nonatomic, copy) NSString* name;

+ (BarcodeFormat *)valueOf:(NSString *)name;

@end

static NSMutableDictionary *values = nil;

@implementation BarcodeFormat

@synthesize name;

- (id)initWithName:(NSString *)aName {
  if (self = [super init]) {
    self.name = aName;
  }
  return self;
}

- (NSString *)description {
  return self.name;
}

+ (BarcodeFormat *)valueOf:(NSString *)name {
  if (!values) {
    values = [[NSMutableDictionary alloc] init];
  }

  BarcodeFormat* format = [values objectForKey:name];

  if (!format) {
    format = [[BarcodeFormat alloc] initWithName:name];
    [values setObject:format forKey:name];
  }

  return format;
}

- (void) dealloc {
  [_name release];
  [super dealloc];
}

/**
 * Aztec 2D barcode format.
 */
+ (BarcodeFormat *)AZTEC {
  return [self valueOf:@"AZTEC"];
}

/**
 * CODABAR 1D format.
 */
+ (BarcodeFormat *)CODABAR {
  return [self valueOf:@"CODABAR"];
}

/**
 * Code 39 1D format.
 */
+ (BarcodeFormat *)CODE_39 {
  return [self valueOf:@"CODE_39"];
}

/**
 * Code 93 1D format.
 */
+ (BarcodeFormat *)CODE_93 {
  return [self valueOf:@"CODE_93"];
}

/**
 * Code 128 1D format.
 */
+ (BarcodeFormat *)CODE_128 {
  return [self valueOf:@"CODE_128"];
}

/**
 * Data Matrix 2D barcode format.
 */
+ (BarcodeFormat *)DATA_MATRIX {
  return [self valueOf:@"DATA_MATRIX"];
}

/**
 * EAN-8 1D format.
 */
+ (BarcodeFormat *)EAN_8 {
  return [self valueOf:@"EAN_8"];
}

/**
 * EAN-13 1D format.
 */
+ (BarcodeFormat *)EAN_13 {
  return [self valueOf:@"EAN_13"];
}

/**
 * ITF (Interleaved Two of Five) 1D format.
 */
+ (BarcodeFormat *)ITF {
  return [self valueOf:@"ITF"];
}

/**
 * PDF417 format.
 */
+ (BarcodeFormat *)PDF_417 {
  return [self valueOf:@"PDF_417"];
}

/**
 * QR Code 2D barcode format.
 */
+ (BarcodeFormat *)QR_CODE {
  return [self valueOf:@"QR_CODE"];
}

/**
 * RSS 14
 */
+ (BarcodeFormat *)RSS_14 {
  return [self valueOf:@"RSS_14"];
}

/**
 * RSS EXPANDED
 */
+ (BarcodeFormat *)RSS_EXPANDED {
  return [self valueOf:@"RSS_EXPANDED"];
}

/**
 * UPC-A 1D format.
 */
+ (BarcodeFormat *)UPC_A {
  return [self valueOf:@"UPC_A"];
}

/**
 * UPC-E 1D format.
 */
+ (BarcodeFormat *)UPC_E {
  return [self valueOf:@"UPC_E"];
}

/**
 * UPC/EAN extension format. Not a stand-alone format.
 */
+ (BarcodeFormat *)UPC_EAN_EXTENSION {
  return [self valueOf:@"UPC_EAN_EXTENSION"];
}

@end
