/**
 * Enumerates barcode formats known to this package. Please keep alphabetized.
 *
 * @author Sean Owen
 */
typedef enum {
  /**
   * Aztec 2D barcode format.
   */
  kBarcodeAztec,

  /**
   * CODABAR 1D format.
   */
  kBarcodeCodabar,

  /**
   * Code 39 1D format.
   */
  kBarcodeCode39,

  /**
   * Code 93 1D format.
   */
  kBarcodeCode93,

  /**
   * Code 128 1D format.
   */
  kBarcodeCode128,

  /**
   * Data Matrix 2D barcode format.
   */
  kBarcodeDataMatrix,

  /**
   * EAN-8 1D format.
   */
  kBarcodeEan8,

  /**
   * EAN-13 1D format.
   */
  kBarcodeEan13,

  /**
   * ITF (Interleaved Two of Five) 1D format.
   */
  kBarcodeEanITF,

  /**
   * PDF417 format.
   */
  kBarcodePDF417,

  /**
   * QR Code 2D barcode format.
   */
  kBarcodeQRCode,

  /**
   * RSS 14
   */
  kBarcodeRSS14,

  /**
   * RSS EXPANDED
   */
  kBarcodeRSSExpanded,

  /**
   * UPC-A 1D format.
   */
  kBarcodeUPCA,

  /**
   * UPC-E 1D format.
   */
  kBarcodeUPCE,

  /**
   * UPC/EAN extension format. Not a stand-alone format.
   */
  kBarcodeUPCEANExtension
} BarcodeFormat;
