
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

extern GenericGF * const AZTEC_DATA_12;
extern GenericGF * const AZTEC_DATA_10;
extern GenericGF * const AZTEC_DATA_6;
extern GenericGF * const AZTEC_PARAM;
extern GenericGF * const QR_CODE_FIELD_256;
extern GenericGF * const DATA_MATRIX_FIELD_256;
extern GenericGF * const AZTEC_DATA_8;

@interface GenericGF : NSObject {
  NSArray * expTable;
  NSArray * logTable;
  GenericGFPoly * zero;
  GenericGFPoly * one;
  int size;
  int primitive;
  BOOL initialized;
}

@property(nonatomic, readonly) int size;
- (id) init:(int)primitive size:(int)size;
- (GenericGFPoly *) getZero;
- (GenericGFPoly *) getOne;
- (GenericGFPoly *) buildMonomial:(int)degree coefficient:(int)coefficient;
+ (int) addOrSubtract:(int)a b:(int)b;
- (int) exp:(int)a;
- (int) log:(int)a;
- (int) inverse:(int)a;
- (int) multiply:(int)a b:(int)b;
@end
