cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-common-detector )

set( HEADER_FILES
    ZXMathUtils.h
    ZXMonochromeRectangleDetector.h
    ZXWhiteRectangleDetector.h )

set( SOURCE_FILES 
    ZXWhiteRectangleDetector.m
    ZXMonochromeRectangleDetector.m
    ZXMathUtils.m )

add_library( common-detector OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_include_directories( common-detector
    PRIVATE
        $<TARGET_PROPERTY:common,INCLUDE_DIRECTORIES>
        $<TARGET_PROPERTY:core,INCLUDE_DIRECTORIES>
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET common-detector APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    