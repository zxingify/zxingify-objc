#import "NSMutableDictionary.h"

/**
 * Enumerates barcode formats known to this package. Please keep alphabetized.
 * 
 * @author Sean Owen
 */


/**
 * Aztec 2D barcode format.
 */
extern BarcodeFormat * const AZTEC;

/**
 * CODABAR 1D format.
 */
extern BarcodeFormat * const CODABAR;

/**
 * Code 39 1D format.
 */
extern BarcodeFormat * const CODE_39;

/**
 * Code 93 1D format.
 */
extern BarcodeFormat * const CODE_93;

/**
 * Code 128 1D format.
 */
extern BarcodeFormat * const CODE_128;

/**
 * Data Matrix 2D barcode format.
 */
extern BarcodeFormat * const DATA_MATRIX;

/**
 * EAN-8 1D format.
 */
extern BarcodeFormat * const EAN_8;

/**
 * EAN-13 1D format.
 */
extern BarcodeFormat * const EAN_13;

/**
 * ITF (Interleaved Two of Five) 1D format.
 */
extern BarcodeFormat * const ITF;

/**
 * PDF417 format.
 */
extern BarcodeFormat * const PDF_417;

/**
 * QR Code 2D barcode format.
 */
extern BarcodeFormat * const QR_CODE;

/**
 * RSS 14
 */
extern BarcodeFormat * const RSS_14;

/**
 * RSS EXPANDED
 */
extern BarcodeFormat * const RSS_EXPANDED;

/**
 * UPC-A 1D format.
 */
extern BarcodeFormat * const UPC_A;

/**
 * UPC-E 1D format.
 */
extern BarcodeFormat * const UPC_E;

/**
 * UPC/EAN extension format. Not a stand-alone format.
 */
extern BarcodeFormat * const UPC_EAN_EXTENSION;

@interface BarcodeFormat : NSObject {
  NSString * name;
}

@property(nonatomic, retain, readonly) NSString * name;
- (NSString *) description;
+ (BarcodeFormat *) valueOf:(NSString *)name;
@end
