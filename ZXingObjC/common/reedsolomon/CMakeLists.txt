cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-common-reedsolomon )

set( HEADER_FILES
    ZXReedSolomonEncoder.h
    ZXGenericGFPoly.h
    ZXGenericGF.h
    ZXReedSolomonDecoder.h )

set( SOURCE_FILES 
    ZXGenericGF.m
    ZXReedSolomonDecoder.m
    ZXReedSolomonEncoder.m
    ZXGenericGFPoly.m )

add_library( common-reedsolomon OBJECT ${HEADER_FILES} ${SOURCE_FILES}  )
target_include_directories( common-reedsolomon
    PRIVATE
        $<TARGET_PROPERTY:common,INCLUDE_DIRECTORIES>
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET common-reedsolomon APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    