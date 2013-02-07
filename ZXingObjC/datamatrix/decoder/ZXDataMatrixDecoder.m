/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXBitMatrix.h"
#import "ZXDataMatrixBitMatrixParser.h"
#import "ZXDataMatrixDataBlock.h"
#import "ZXDataMatrixDecodedBitStreamParser.h"
#import "ZXDataMatrixDecoder.h"
#import "ZXDataMatrixVersion.h"
#import "ZXDecoderResult.h"
#import "ZXErrors.h"
#import "ZXGenericGF.h"
#import "ZXReedSolomonDecoder.h"

@interface ZXDataMatrixDecoder ()

@property (nonatomic, retain) ZXReedSolomonDecoder *rsDecoder;

- (BOOL)correctErrors:(NSMutableArray *)codewordBytes numDataCodewords:(int)numDataCodewords error:(NSError **)error;

@end

@implementation ZXDataMatrixDecoder

@synthesize rsDecoder;

- (id) init {
  if (self = [super init]) {
    self.rsDecoder = [[[ZXReedSolomonDecoder alloc] initWithField:[ZXGenericGF DataMatrixField256]] autorelease];
  }

  return self;
}

- (void) dealloc {
  [rsDecoder release];

  [super dealloc];
}


/**
 * Convenience method that can decode a Data Matrix Code represented as a 2D array of booleans.
 * "true" is taken to mean a black module.
 */
- (ZXDecoderResult *)decode:(BOOL **)image length:(unsigned int)length error:(NSError **)error {
  int dimension = length;
  ZXBitMatrix *bits = [[[ZXBitMatrix alloc] initWithDimension:dimension] autorelease];
  for (int i = 0; i < dimension; i++) {
    for (int j = 0; j < dimension; j++) {
      if (image[i][j]) {
        [bits setX:j y:i];
      }
    }
  }

  return [self decodeMatrix:bits error:error];
}


/**
 * Decodes a Data Matrix Code represented as a BitMatrix. A 1 or "true" is taken
 * to mean a black module.
 */
- (ZXDecoderResult *)decodeMatrix:(ZXBitMatrix *)bits error:(NSError **)error {
  ZXDataMatrixBitMatrixParser *parser = [[[ZXDataMatrixBitMatrixParser alloc] initWithBitMatrix:bits error:error] autorelease];
  if (!parser) {
    return nil;
  }
  ZXDataMatrixVersion *version = [parser version];

  NSArray *codewords = [parser readCodewords];
  NSArray *dataBlocks = [ZXDataMatrixDataBlock dataBlocks:codewords version:version];

  int dataBlocksCount = [dataBlocks count];

  int totalBytes = 0;
  for (int i = 0; i < dataBlocksCount; i++) {
    totalBytes += [[dataBlocks objectAtIndex:i] numDataCodewords];
  }

  if (totalBytes == 0) {
    return nil;
  }

  unsigned char resultBytes[totalBytes];

  for (int j = 0; j < dataBlocksCount; j++) {
    ZXDataMatrixDataBlock *dataBlock = [dataBlocks objectAtIndex:j];
    NSMutableArray *codewordBytes = dataBlock.codewords;
    int numDataCodewords = [dataBlock numDataCodewords];
    if (![self correctErrors:codewordBytes numDataCodewords:numDataCodewords error:error]) {
      return nil;
    }
    for (int i = 0; i < numDataCodewords; i++) {
      resultBytes[i * dataBlocksCount + j] = [[codewordBytes objectAtIndex:i] charValue];
    }
  }

  return [ZXDataMatrixDecodedBitStreamParser decode:resultBytes length:totalBytes error:error];
}


/**
 * Given data and error-correction codewords received, possibly corrupted by errors, attempts to
 * correct the errors in-place using Reed-Solomon error correction.
 */
- (BOOL)correctErrors:(NSMutableArray *)codewordBytes numDataCodewords:(int)numDataCodewords error:(NSError **)error {
  int numCodewords = [codewordBytes count];
  int codewordsInts[numCodewords];
  for (int i = 0; i < numCodewords; i++) {
    codewordsInts[i] = [[codewordBytes objectAtIndex:i] charValue] & 0xFF;
  }
  int numECCodewords = [codewordBytes count] - numDataCodewords;

  NSError *decodeError = nil;
  if (![rsDecoder decode:codewordsInts receivedLen:numCodewords twoS:numECCodewords error:&decodeError]) {
    if (decodeError.code == ZXReedSolomonError) {
      if (error) *error = ChecksumErrorInstance();
      return NO;
    } else {
      if (error) *error = decodeError;
      return NO;
    }
  }

  for (int i = 0; i < numDataCodewords; i++) {
    [codewordBytes replaceObjectAtIndex:i withObject:[NSNumber numberWithChar:codewordsInts[i]]];
  }
  return YES;
}

@end
