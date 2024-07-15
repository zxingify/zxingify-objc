cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-client-result )

set( HEADER_FILES
    ZXEmailAddressParsedResult.h
    ZXSMSMMSResultParser.h
    ZXAddressBookAUResultParser.h
    ZXSMTPResultParser.h
    ZXResultParser.h
    ZXBizcardResultParser.h
    ZXTextParsedResult.h
    ZXURIParsedResult.h
    ZXTelParsedResult.h
    ZXProductParsedResult.h
    ZXGeoParsedResult.h
    ZXBookmarkDoCoMoResultParser.h
    ZXWifiParsedResult.h
    ZXParsedResultType.h
    ZXISBNParsedResult.h
    ZXVINParsedResult.h
    ZXCalendarParsedResult.h
    ZXSMSParsedResult.h
    ZXExpandedProductParsedResult.h
    ZXSMSTOMMSTOResultParser.h
    ZXVCardResultParser.h
    ZXURIResultParser.h
    ZXAbstractDoCoMoResultParser.h
    ZXParsedResult.h
    ZXEmailAddressResultParser.h
    ZXEmailDoCoMoResultParser.h
    ZXAddressBookDoCoMoResultParser.h
    ZXProductResultParser.h
    ZXVEventResultParser.h
    ZXTelResultParser.h
    ZXWifiResultParser.h
    ZXGeoResultParser.h
    ZXExpandedProductResultParser.h
    ZXAddressBookParsedResult.h
    ZXISBNResultParser.h
    ZXURLTOResultParser.h
    ZXVINResultParser.h )

set( SOURCE_FILES 
    ZXEmailAddressResultParser.m
    ZXParsedResult.m
    ZXURIResultParser.m
    ZXAbstractDoCoMoResultParser.m
    ZXVCardResultParser.m
    ZXTelResultParser.m
    ZXVEventResultParser.m
    ZXProductResultParser.m
    ZXAddressBookDoCoMoResultParser.m
    ZXEmailDoCoMoResultParser.m
    ZXGeoResultParser.m
    ZXWifiResultParser.m
    ZXURLTOResultParser.m
    ZXVINResultParser.m
    ZXISBNResultParser.m
    ZXAddressBookParsedResult.m
    ZXExpandedProductResultParser.m
    ZXTextParsedResult.m
    ZXURIParsedResult.m
    ZXBizcardResultParser.m
    ZXResultParser.m
    ZXSMTPResultParser.m
    ZXAddressBookAUResultParser.m
    ZXSMSMMSResultParser.m
    ZXEmailAddressParsedResult.m
    ZXProductParsedResult.m
    ZXTelParsedResult.m
    ZXBookmarkDoCoMoResultParser.m
    ZXWifiParsedResult.m
    ZXGeoParsedResult.m
    ZXSMSTOMMSTOResultParser.m
    ZXExpandedProductParsedResult.m
    ZXSMSParsedResult.m
    ZXCalendarParsedResult.m
    ZXVINParsedResult.m
    ZXISBNParsedResult.m )

add_library( client-result OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_link_libraries( client-result PRIVATE common core oned )
target_include_directories( client-result
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET client-result APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    