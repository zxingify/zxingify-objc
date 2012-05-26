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

/**
 * Represents a record in an NDEF message. This class only supports certain types
 * of records -- namely, non-chunked records, where ID length is omitted, and only
 * "short records".
 */

extern NSString * const TEXT_WELL_KNOWN_TYPE;
extern NSString * const URI_WELL_KNOWN_TYPE;
extern NSString * const SMART_POSTER_WELL_KNOWN_TYPE;
extern NSString * const ACTION_WELL_KNOWN_TYPE;

@interface ZXNDEFRecord : NSObject

@property (nonatomic, copy, readonly) NSString * type;
@property (nonatomic, readonly) unsigned char * payload;
@property (nonatomic, readonly) int payloadLength;
@property (nonatomic, readonly) int totalRecordLength;

+ (ZXNDEFRecord *)readRecord:(unsigned char *)bytes offset:(int)offset;
- (BOOL)messageBegin;
- (BOOL)messageEnd;

@end
