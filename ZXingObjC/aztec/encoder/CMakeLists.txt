cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-aztec-encoder )

set( HEADER_FILES
    ZXAztecEncoder.h
    ZXAztecHighLevelEncoder.h
    ZXAztecSimpleToken.h
    ZXAztecBinaryShiftToken.h
    ZXAztecState.h
    ZXAztecToken.h
    ZXAztecCode.h )

set( SOURCE_FILES 
    ZXAztecToken.m
    ZXAztecState.m
    ZXAztecBinaryShiftToken.m
    ZXAztecCode.m
    ZXAztecHighLevelEncoder.m
    ZXAztecEncoder.m
    ZXAztecSimpleToken.m )

add_library( aztec-encoder OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_link_libraries( aztec-encoder PRIVATE common common-reedsolomon )
target_include_directories( aztec-encoder
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET aztec-encoder APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    