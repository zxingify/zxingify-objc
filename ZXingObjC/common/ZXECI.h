/**
 * Superclass of classes encapsulating types ECIs, according to "Extended Channel Interpretations"
 * 5.3 of ISO 18004.
 */

@interface ZXECI : NSObject

@property (nonatomic, readonly) int value;

- (id)initWithValue:(int)value;
+ (ZXECI *)eciByValue:(int)value;

@end
