cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-qrcode-detector )

set( HEADER_FILES
    ZXQRCodeAlignmentPatternFinder.h
    ZXQRCodeFinderPattern.h
    ZXQRCodeDetector.h
    ZXQRCodeFinderPatternFinder.h
    ZXQRCodeFinderPatternInfo.h
    ZXQRCodeAlignmentPattern.h )

set( SOURCE_FILES 
    ZXQRCodeFinderPatternInfo.m
    ZXQRCodeAlignmentPattern.m
    ZXQRCodeFinderPattern.m
    ZXQRCodeAlignmentPatternFinder.m
    ZXQRCodeFinderPatternFinder.m
    ZXQRCodeDetector.m )

add_library( qrcode-detector OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_link_libraries( qrcode-detector PRIVATE common common-detector core qrcode-decoder )
target_include_directories( qrcode-detector
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET qrcode-detector APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    