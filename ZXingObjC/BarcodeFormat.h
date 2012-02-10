/**
 * Enumerates barcode formats known to this package. Please keep alphabetized.
 *
 * @author Sean Owen
 */
typedef enum {
  /**
   * Aztec 2D barcode format.
   */
  kBarcodeFormatAztec,

  /**
   * CODABAR 1D format.
   */
  kBarcodeFormatCodabar,

  /**
   * Code 39 1D format.
   */
  kBarcodeFormatCode39,

  /**
   * Code 93 1D format.
   */
  kBarcodeFormatCode93,

  /**
   * Code 128 1D format.
   */
  kBarcodeFormatCode128,

  /**
   * Data Matrix 2D barcode format.
   */
  kBarcodeFormatDataMatrix,

  /**
   * EAN-8 1D format.
   */
  kBarcodeFormatEan8,

  /**
   * EAN-13 1D format.
   */
  kBarcodeFormatEan13,

  /**
   * ITF (Interleaved Two of Five) 1D format.
   */
  kBarcodeFormatITF,

  /**
   * PDF417 format.
   */
  kBarcodeFormatPDF417,

  /**
   * QR Code 2D barcode format.
   */
  kBarcodeFormatQRCode,

  /**
   * RSS 14
   */
  kBarcodeFormatRSS14,

  /**
   * RSS EXPANDED
   */
  kBarcodeFormatRSSExpanded,

  /**
   * UPC-A 1D format.
   */
  kBarcodeFormatUPCA,

  /**
   * UPC-E 1D format.
   */
  kBarcodeFormatUPCE,

  /**
   * UPC/EAN extension format. Not a stand-alone format.
   */
  kBarcodeFormatUPCEANExtension
} BarcodeFormat;
