cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-multi )

set( HEADER_FILES
    ZXGenericMultipleBarcodeReader.h
    ZXByQuadrantReader.h
    ZXMultipleBarcodeReader.h )

set( SOURCE_FILES 
    ZXGenericMultipleBarcodeReader.m
    ZXByQuadrantReader.m )

add_library( multi OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_link_libraries( multi PRIVATE common core )
target_include_directories( multi
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET multi APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    