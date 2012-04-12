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

@class ZXGenericGFPoly;

@interface ZXGenericGF : NSObject {
  NSMutableArray * expTable;
  NSMutableArray * logTable;
  ZXGenericGFPoly * zero;
  ZXGenericGFPoly * one;
  int size;
  int primitive;
  BOOL initialized;
}

@property(nonatomic, readonly) ZXGenericGFPoly * one;
@property(nonatomic, readonly) int size;
@property(nonatomic, readonly) ZXGenericGFPoly * zero;

+ (ZXGenericGF *)AztecData12;
+ (ZXGenericGF *)AztecData10;
+ (ZXGenericGF *)AztecData6;
+ (ZXGenericGF *)AztecDataParam;
+ (ZXGenericGF *)QrCodeField256;
+ (ZXGenericGF *)DataMatrixField256;
+ (ZXGenericGF *)AztecData8;

- (id) initWithPrimitive:(int)primitive size:(int)size;
- (ZXGenericGFPoly *) buildMonomial:(int)degree coefficient:(int)coefficient;
+ (int) addOrSubtract:(int)a b:(int)b;
- (int) exp:(int)a;
- (int) log:(int)a;
- (int) inverse:(int)a;
- (int) multiply:(int)a b:(int)b;

@end
