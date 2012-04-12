/**
 * Represents the type of data encoded by a barcode -- from plain text, to a
 * URI, to an e-mail address, etc.
 * 
 * @author Sean Owen
 */
typedef enum {
  kParsedResultTypeAddressBook,
  kParsedResultTypeEmailAddress,
  kParsedResultTypeProduct,
  kParsedResultTypeURI,
  kParsedResultTypeText,
  kParsedResultTypeAndroidIntent,
  kParsedResultTypeGeo,
  kParsedResultTypeTel,
  kParsedResultTypeSMS,
  kParsedResultTypeCalendar,
  kParsedResultTypeWifi,
  kParsedResultTypeNDEFSMartPoster,
  kParsedResultTypeMobiletagRichWeb,
  kParsedResultTypeISBN
} ZXParsedResultType;
