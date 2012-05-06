#import "ZXAbstractNDEFResultParser.h"

/**
 * Recognizes an NDEF message that encodes information according to the
 * "Smart Poster Record Type Definition" specification.
 * 
 * This actually only supports some parts of the Smart Poster format: title,
 * URI, and action records. Icon records are not supported because the size
 * of these records are infeasibly large for barcodes. Size and type records
 * are not supported. Multiple titles are not supported.
 */

@class ZXNDEFSmartPosterParsedResult, ZXResult;

@interface ZXNDEFSmartPosterResultParser : ZXAbstractNDEFResultParser

+ (ZXNDEFSmartPosterParsedResult *)parse:(ZXResult *)result;

@end
