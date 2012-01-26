#import "SMSParsedResult.h"

@implementation SMSParsedResult

@synthesize sMSURI;
@synthesize numbers;
@synthesize vias;
@synthesize subject;
@synthesize body;
@synthesize displayResult;

- (id) init:(NSString *)number via:(NSString *)via subject:(NSString *)subject body:(NSString *)body {
  if (self = [super init:ParsedResultType.SMS]) {
    numbers = [NSArray arrayWithObjects:number, nil];
    vias = [NSArray arrayWithObjects:via, nil];
    subject = subject;
    body = body;
  }
  return self;
}

- (id) init:(NSArray *)numbers vias:(NSArray *)vias subject:(NSString *)subject body:(NSString *)body {
  if (self = [super init:ParsedResultType.SMS]) {
    numbers = numbers;
    vias = vias;
    subject = subject;
    body = body;
  }
  return self;
}

- (NSString *) sMSURI {
  StringBuffer * result = [[[StringBuffer alloc] init] autorelease];
  [result append:@"sms:"];
  BOOL first = YES;

  for (int i = 0; i < numbers.length; i++) {
    if (first) {
      first = NO;
    }
     else {
      [result append:','];
    }
    [result append:numbers[i]];
    if (vias[i] != nil) {
      [result append:@";via="];
      [result append:vias[i]];
    }
  }

  BOOL hasBody = body != nil;
  BOOL hasSubject = subject != nil;
  if (hasBody || hasSubject) {
    [result append:'?'];
    if (hasBody) {
      [result append:@"body="];
      [result append:body];
    }
    if (hasSubject) {
      if (hasBody) {
        [result append:'&'];
      }
      [result append:@"subject="];
      [result append:subject];
    }
  }
  return [result description];
}

- (NSString *) displayResult {
  StringBuffer * result = [[[StringBuffer alloc] init:100] autorelease];
  [self maybeAppend:numbers param1:result];
  [self maybeAppend:subject param1:result];
  [self maybeAppend:body param1:result];
  return [result description];
}

- (void) dealloc {
  [numbers release];
  [vias release];
  [subject release];
  [body release];
  [super dealloc];
}

@end
