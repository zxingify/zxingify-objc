cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-oned-rss-expanded-decoders )

set( HEADER_FILES
    ZXAI01320xDecoder.h
    ZXAI01393xDecoder.h
    ZXRSSExpandedDecodedObject.h
    ZXAI01decoder.h
    ZXRSSExpandedGeneralAppIdDecoder.h
    ZXRSSExpandedCurrentParsingState.h
    ZXAI01392xDecoder.h
    ZXRSSExpandedDecodedNumeric.h
    ZXAbstractExpandedDecoder.h
    ZXAI013x0xDecoder.h
    ZXRSSExpandedBlockParsedResult.h
    ZXAnyAIDecoder.h
    ZXAI01weightDecoder.h
    ZXRSSExpandedDecodedChar.h
    ZXAI013x0x1xDecoder.h
    ZXRSSExpandedFieldParser.h
    ZXRSSExpandedDecodedInformation.h
    ZXAI013103decoder.h
    ZXAI01AndOtherAIs.h )

set( SOURCE_FILES 
    ZXAI01weightDecoder.m
    ZXAnyAIDecoder.m
    ZXRSSExpandedBlockParsedResult.m
    ZXAI013x0x1xDecoder.m
    ZXRSSExpandedDecodedChar.m
    ZXRSSExpandedDecodedInformation.m
    ZXAI013103decoder.m
    ZXRSSExpandedFieldParser.m
    ZXAI01AndOtherAIs.m
    ZXRSSExpandedDecodedObject.m
    ZXAI01393xDecoder.m
    ZXAI01320xDecoder.m
    ZXRSSExpandedCurrentParsingState.m
    ZXRSSExpandedGeneralAppIdDecoder.m
    ZXAI01decoder.m
    ZXAbstractExpandedDecoder.m
    ZXRSSExpandedDecodedNumeric.m
    ZXAI01392xDecoder.m
    ZXAI013x0xDecoder.m )

add_library( oned-rss-expanded-decoders OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_link_libraries( oned-rss-expanded-decoders PRIVATE common core )
target_include_directories( oned-rss-expanded-decoders
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET oned-rss-expanded-decoders APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    