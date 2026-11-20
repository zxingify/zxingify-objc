cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-pdf417-detector )

set( HEADER_FILES
    ZXPDF417DetectorResult.h
    ZXPDF417Detector.h )

set( SOURCE_FILES 
    ZXPDF417DetectorResult.m
    ZXPDF417Detector.m )

add_library( pdf417-detector OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_link_libraries( pdf417-detector PRIVATE common common-detector core )
target_include_directories( pdf417-detector
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET pdf417-detector APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    