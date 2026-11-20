cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-oned-rss )

set( HEADER_FILES
    ZXRSSFinderPattern.h
    ZXRSSPair.h
    ZXRSSDataCharacter.h
    ZXRSS14Reader.h
    ZXRSSUtils.h
    ZXAbstractRSSReader.h )

set( SOURCE_FILES 
    ZXRSS14Reader.m
    ZXRSSDataCharacter.m
    ZXRSSPair.m
    ZXRSSUtils.m
    ZXAbstractRSSReader.m
    ZXRSSFinderPattern.m )

add_library( oned-rss OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_link_libraries( oned-rss core )
target_include_directories( oned-rss
    PRIVATE
        $<TARGET_PROPERTY:oned,INCLUDE_DIRECTORIES>
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET oned-rss APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    
add_subdirectory( expanded )
