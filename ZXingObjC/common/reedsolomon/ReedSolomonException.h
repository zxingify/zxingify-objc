
/**
 * <p>Thrown when an exception occurs during Reed-Solomon decoding, such as when
 * there are too many errors to correct.</p>
 * 
 * @author Sean Owen
 */

@interface ReedSolomonException : NSException {
}

- (id) initWithMessage:(NSString *)message;
@end
