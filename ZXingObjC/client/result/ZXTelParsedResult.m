#import "ZXTelParsedResult.h"

@interface ZXTelParsedResult ()

@property (nonatomic, copy) NSString * number;
@property (nonatomic, copy) NSString * telURI;
@property (nonatomic, copy) NSString * title;

@end

@implementation ZXTelParsedResult

@synthesize number;
@synthesize telURI;
@synthesize title;

- (id)initWithNumber:(NSString *)aNumber telURI:(NSString *)aTelURI title:(NSString *)aTitle {
  if (self = [super initWithType:kParsedResultTypeTel]) {
    self.number = aNumber;
    self.telURI = aTelURI;
    self.title = aTitle;
  }

  return self;
}

- (void)dealloc {
  [number release];
  [telURI release];
  [title release];

  [super dealloc];
}

- (NSString *)displayResult {
  NSMutableString *result = [NSMutableString stringWithCapacity:20];
  [ZXParsedResult maybeAppend:number result:result];
  [ZXParsedResult maybeAppend:title result:result];
  return [NSString stringWithString:result];
}

@end
