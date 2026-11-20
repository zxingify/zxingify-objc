cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-aztec-detector )

set( HEADER_FILES
    ZXAztecDetector.h )

set( SOURCE_FILES 
    ZXAztecDetector.m )

add_library( aztec-detector OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_include_directories( aztec-detector
    PRIVATE
        $<TARGET_PROPERTY:aztec,INCLUDE_DIRECTORIES>
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET aztec-detector APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    