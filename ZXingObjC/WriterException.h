
/**
 * A base class which covers the range of exceptions which may occur when encoding a barcode using
 * the Writer framework.
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 */

@interface WriterException : NSException {
}

- (id) init;
- (id) initWithMessage:(NSString *)message;
@end
