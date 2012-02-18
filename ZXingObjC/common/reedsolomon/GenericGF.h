/**
 * <p>This class contains utility methods for performing mathematical operations over
 * the Galois Fields. Operations use a given primitive polynomial in calculations.</p>
 * 
 * <p>Throughout this package, elements of the GF are represented as an <code>int</code>
 * for convenience and speed (but at the cost of memory).
 * </p>
 * 
 * @author Sean Owen
 * @author David Olivier
 */

@class GenericGFPoly;

@interface GenericGF : NSObject {
  NSMutableArray * expTable;
  NSMutableArray * logTable;
  GenericGFPoly * zero;
  GenericGFPoly * one;
  int size;
  int primitive;
  BOOL initialized;
}

@property(nonatomic, readonly) GenericGFPoly * one;
@property(nonatomic, readonly) int size;
@property(nonatomic, readonly) GenericGFPoly * zero;

+ (GenericGF *)AztecData12;
+ (GenericGF *)AztecData10;
+ (GenericGF *)AztecData6;
+ (GenericGF *)AztecDataParam;
+ (GenericGF *)QrCodeField256;
+ (GenericGF *)DataMatrixField256;
+ (GenericGF *)AztecData8;

- (id) initWithPrimitive:(int)primitive size:(int)size;
- (GenericGFPoly *) buildMonomial:(int)degree coefficient:(int)coefficient;
+ (int) addOrSubtract:(int)a b:(int)b;
- (int) exp:(int)a;
- (int) log:(int)a;
- (int) inverse:(int)a;
- (int) multiply:(int)a b:(int)b;

@end
