cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-oned-rss-expanded )

set( HEADER_FILES
    ZXBitArrayBuilder.h
    ZXRSSExpandedPair.h
    ZXRSSExpandedRow.h
    ZXRSSExpandedReader.h )

set( SOURCE_FILES 
    ZXRSSExpandedRow.m
    ZXRSSExpandedPair.m
    ZXBitArrayBuilder.m
    ZXRSSExpandedReader.m )

add_library( oned-rss-expanded OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_include_directories( oned-rss-expanded
    PRIVATE
        $<TARGET_PROPERTY:oned-rss,INCLUDE_DIRECTORIES>
        $<TARGET_PROPERTY:oned-rss-expanded-decoders,INCLUDE_DIRECTORIES>
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET oned-rss-expanded APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    
add_subdirectory( decoders )
