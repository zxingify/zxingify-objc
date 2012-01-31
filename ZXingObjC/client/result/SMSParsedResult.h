#import "ParsedResult.h"

/**
 * @author Sean Owen
 */

@interface SMSParsedResult : ParsedResult {
  NSArray * numbers;
  NSArray * vias;
  NSString * subject;
  NSString * body;
}

@property(nonatomic, retain, readonly) NSString * sMSURI;
@property(nonatomic, retain, readonly) NSArray * numbers;
@property(nonatomic, retain, readonly) NSArray * vias;
@property(nonatomic, retain, readonly) NSString * subject;
@property(nonatomic, retain, readonly) NSString * body;
@property(nonatomic, retain, readonly) NSString * displayResult;
- (id)initWithNumber:(NSString *)number via:(NSString *)via subject:(NSString *)subject body:(NSString *)body;
- (id)initWithNumbers:(NSArray *)numbers vias:(NSArray *)vias subject:(NSString *)subject body:(NSString *)body;

@end
