#import "ZXSMSParsedResult.h"

@interface ZXSMSParsedResult ()

@property (nonatomic, retain) NSArray * numbers;
@property (nonatomic, retain) NSArray * vias;
@property (nonatomic, copy) NSString * subject;
@property (nonatomic, copy) NSString * body;

@end

@implementation ZXSMSParsedResult

@synthesize numbers;
@synthesize vias;
@synthesize subject;
@synthesize body;

- (id)initWithNumber:(NSString *)aNumber via:(NSString *)aVia subject:(NSString *)aSubject body:(NSString *)aBody {
  NSArray* theNumbers = nil;
  if (aNumber) {
    theNumbers = [NSArray arrayWithObject:aNumber];
  }

  NSArray* theVias = nil;
  if (aVia) {
    theVias = [NSArray arrayWithObject:aVia];
  }
  
  return [self initWithNumbers:theNumbers vias:theVias subject:aSubject body:aBody];
}

- (id)initWithNumbers:(NSArray *)theNumbers vias:(NSArray *)theVias subject:(NSString *)aSubject body:(NSString *)aBody {
  if (self = [super initWithType:kParsedResultTypeSMS]) {
    self.numbers = theNumbers;
    self.vias = theVias;
    self.subject = aSubject;
    self.body = aBody;
  }

  return self;
}

- (void) dealloc {
  [numbers release];
  [vias release];
  [subject release];
  [body release];

  [super dealloc];
}

- (NSString *)sMSURI {
  NSMutableString* result = [NSMutableString stringWithString:@"sms:"];
  BOOL first = YES;
  for (int i = 0; i < self.numbers.count; i++) {
    if (first) {
      first = NO;
    } else {
      [result appendString:@","];
    }
    [result appendString:[numbers objectAtIndex:i]];
    if ([vias objectAtIndex:i] != nil) {
      [result appendString:@";via="];
      [result appendString:[vias objectAtIndex:i]];
    }
  }

  BOOL hasBody = body != nil;
  BOOL hasSubject = subject != nil;
  if (hasBody || hasSubject) {
    [result appendString:@"?"];
    if (hasBody) {
      [result appendString:@"body="];
      [result appendString:body];
    }
    if (hasSubject) {
      if (hasBody) {
        [result appendString:@"&"];
      }
      [result appendString:@"subject="];
      [result appendString:subject];
    }
  }
  return [NSString stringWithString:result];
}

- (NSString *)displayResult {
  NSMutableString* result = [NSMutableString stringWithCapacity:100];
  [ZXParsedResult maybeAppendArray:numbers result:result];
  [ZXParsedResult maybeAppend:subject result:result];
  [ZXParsedResult maybeAppend:body result:result];
  return [NSString stringWithString:result];
}

@end
