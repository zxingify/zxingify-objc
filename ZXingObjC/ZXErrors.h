#define ZXErrorDomain @"ZXErrorDomain"

enum {
  /**
   * Thrown when a barcode was successfully detected and decoded, but
   * was not returned because its checksum feature failed.
   */
  ZXChecksumError     = 1000,

  /**
   * Thrown when a barcode was successfully detected, but some aspect of
   * the content did not conform to the barcode's format rules. This could have
   * been due to a mis-detection.
   */
  ZXFormatError       = 1001,

  /**
   * Thrown when a barcode was not found in the image. It might have been
   * partially detected but could not be confirmed.
   */
  ZXNotFoundError     = 1002,

  /**
   * Thrown when an exception occurs during Reed-Solomon decoding, such as when
   * there are too many errors to correct.
   */
  ZXReedSolomonError  = 1003,

  /**
   * This general error is thrown when something goes wrong during decoding of a barcode.
   * This includes, but is not limited to, failing checksums / error correction algorithms, being
   * unable to locate finder timing patterns, and so on.
   */
  ZXReaderError       = 1004,

  /**
   * Covers the range of error which may occur when encoding a barcode using the Writer framework.
   */
  ZXWriterError       = 1005
};

// Helper methods for error instances
NSError* ChecksumErrorInstance();
NSError* FormatErrorInstance();
NSError* NotFoundErrorInstance();
