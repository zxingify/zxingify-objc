/**
 * Enumerates barcode formats known to this package. Please keep alphabetized.
 * 
 * @author Sean Owen
 */

@interface BarcodeFormat : NSObject

- (id)initWithName:(NSString *)name;

/**
 * Aztec 2D barcode format.
 */
+ (BarcodeFormat *)AZTEC;

/**
 * CODABAR 1D format.
 */
+ (BarcodeFormat *)CODABAR;

/**
 * Code 39 1D format.
 */
+ (BarcodeFormat *)CODE_39;

/**
 * Code 93 1D format.
 */
+ (BarcodeFormat *)CODE_93;

/**
 * Code 128 1D format.
 */
+ (BarcodeFormat *)CODE_128;

/**
 * Data Matrix 2D barcode format.
 */
+ (BarcodeFormat *)DATA_MATRIX;

/**
 * EAN-8 1D format.
 */
+ (BarcodeFormat *)EAN_8;

/**
 * EAN-13 1D format.
 */
+ (BarcodeFormat *)EAN_13;

/**
 * ITF (Interleaved Two of Five) 1D format.
 */
+ (BarcodeFormat *)ITF;

/**
 * PDF417 format.
 */
+ (BarcodeFormat *)PDF_417;

/**
 * QR Code 2D barcode format.
 */
+ (BarcodeFormat *)QR_CODE;

/**
 * RSS 14
 */
+ (BarcodeFormat *)RSS_14;

/**
 * RSS EXPANDED
 */
+ (BarcodeFormat *)RSS_EXPANDED;

/**
 * UPC-A 1D format.
 */
+ (BarcodeFormat *)UPC_A;

/**
 * UPC-E 1D format.
 */
+ (BarcodeFormat *)UPC_E;

/**
 * UPC/EAN extension format. Not a stand-alone format.
 */
+ (BarcodeFormat *)UPC_EAN_EXTENSION;

@end
