#import "ZXSMSParsedResult.h"

@implementation ZXSMSParsedResult

@synthesize sMSURI;
@synthesize numbers;
@synthesize vias;
@synthesize subject;
@synthesize body;
@synthesize displayResult;

- (id)initWithNumber:(NSString *)number via:(NSString *)via subject:(NSString *)aSubject body:(NSString *)aBody {
  if (self = [super initWithType:kParsedResultTypeSMS]) {
    numbers = [NSArray arrayWithObjects:number, nil];
    vias = [NSArray arrayWithObjects:via, nil];
    subject = [aSubject copy];
    body = [aBody copy];
  }
  return self;
}

- (id)initWithNumbers:(NSArray *)theNumbers vias:(NSArray *)theVias subject:(NSString *)aSubject body:(NSString *)aBody {
  if (self = [super initWithType:kParsedResultTypeSMS]) {
    numbers = [theNumbers retain];
    vias = [theVias retain];
    subject = [aSubject copy];
    body = [aBody copy];
  }
  return self;
}

- (NSString *)sMSURI {
  NSMutableString* result = [NSMutableString stringWithString:@"sms:"];

  BOOL first = YES;

  for (int i = 0; i < [numbers count]; i++) {
    if (first) {
      first = NO;
    }
     else {
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
  return result;
}

- (NSString *)displayResult {
  NSMutableString* result = [NSMutableString stringWithCapacity:100];
  [ZXParsedResult maybeAppendArray:numbers result:result];
  [ZXParsedResult maybeAppend:subject result:result];
  [ZXParsedResult maybeAppend:body result:result];
  return result;
}

- (void) dealloc {
  [numbers release];
  [vias release];
  [subject release];
  [body release];
  [super dealloc];
}

@end
