cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-aztec-decoder )

set( HEADER_FILES
    ZXAztecDecoder.h )

set( SOURCE_FILES 
    ZXAztecDecoder.m )

add_library( aztec-decoder OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_link_libraries( aztec-decoder PRIVATE common )
target_include_directories( aztec-decoder
    PRIVATE
        $<TARGET_PROPERTY:aztec,INCLUDE_DIRECTORIES>
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET aztec-decoder APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    