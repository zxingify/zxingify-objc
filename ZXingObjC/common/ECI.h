
/**
 * Superclass of classes encapsulating types ECIs, according to "Extended Channel Interpretations"
 * 5.3 of ISO 18004.
 * 
 * @author Sean Owen
 */

@interface ECI : NSObject

@property(nonatomic, assign) int value;

- (id) initWithValue:(int)value;
+ (ECI *) getECIByValue:(int)value;

@end
