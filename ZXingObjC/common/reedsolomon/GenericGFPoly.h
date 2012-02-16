/**
 * <p>Represents a polynomial whose coefficients are elements of a GF.
 * Instances of this class are immutable.</p>
 * 
 * <p>Much credit is due to William Rucklidge since portions of this code are an indirect
 * port of his C++ Reed-Solomon implementation.</p>
 * 
 * @author Sean Owen
 */

@class GenericGF;

@interface GenericGFPoly : NSObject {
  GenericGF * field;
  NSArray * coefficients;
}

@property (nonatomic, readonly) NSArray* coefficients;

- (id) initWithField:(GenericGF *)field coefficients:(NSArray *)coefficients;
- (int) degree;
- (BOOL) zero;
- (int) coefficient:(int)degree;
- (int) evaluateAt:(int)a;
- (GenericGFPoly *) addOrSubtract:(GenericGFPoly *)other;
- (GenericGFPoly *) multiply:(GenericGFPoly *)other;
- (GenericGFPoly *) multiplyScalar:(int)scalar;
- (GenericGFPoly *) multiplyByMonomial:(int)degree coefficient:(int)coefficient;
- (NSArray *) divide:(GenericGFPoly *)other;

@end
