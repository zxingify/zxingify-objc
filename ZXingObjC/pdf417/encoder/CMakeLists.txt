cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-pdf417-encoder )

set( HEADER_FILES
    ZXPDF417BarcodeMatrix.h
    ZXPDF417ErrorCorrection.h
    ZXPDF417HighLevelEncoder.h
    ZXPDF417Dimensions.h
    ZXPDF417.h
    ZXPDF417BarcodeRow.h )

set( SOURCE_FILES 
    ZXPDF417ErrorCorrection.m
    ZXPDF417BarcodeMatrix.m
    ZXPDF417Dimensions.m
    ZXPDF417HighLevelEncoder.m
    ZXPDF417BarcodeRow.m
    ZXPDF417.m )

add_library( pdf417-encoder OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_link_libraries( pdf417-encoder PRIVATE common core )
target_include_directories( pdf417-encoder
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET pdf417-encoder APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    