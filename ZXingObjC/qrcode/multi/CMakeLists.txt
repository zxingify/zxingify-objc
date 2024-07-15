cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-qrcode-multi )

set( HEADER_FILES
    ZXQRCodeMultiReader.h )

set( SOURCE_FILES 
    ZXQRCodeMultiReader.m )

add_library( qrcode-multi OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_link_libraries( qrcode-multi
    PRIVATE
        common
        common-detector
        core
        multi
        qrcode-decoder
        qrcode-detector
        qrcode-multi-detector )
target_include_directories( qrcode-multi
    PRIVATE
        $<TARGET_PROPERTY:qrcode,INCLUDE_DIRECTORIES>
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET qrcode-multi APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    
add_subdirectory( detector )
