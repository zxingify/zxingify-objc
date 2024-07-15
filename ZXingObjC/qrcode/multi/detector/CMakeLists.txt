cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-qrcode-multi-detector )

set( HEADER_FILES
    ZXMultiDetector.h
    ZXMultiFinderPatternFinder.h )

set( SOURCE_FILES 
    ZXMultiFinderPatternFinder.m
    ZXMultiDetector.m )

add_library( qrcode-multi-detector OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_link_libraries( qrcode-multi-detector PRIVATE common qrcode-detector )
target_include_directories( qrcode-multi-detector
    PRIVATE
        $<TARGET_PROPERTY:qrcode,INCLUDE_DIRECTORIES>
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET qrcode-multi-detector APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    