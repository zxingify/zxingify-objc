cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-qrcode )

set( HEADER_FILES
    ZXingObjCQRCode.h
    ZXQRCodeReader.h
    ZXQRCodeWriter.h )

set( SOURCE_FILES 
    ZXQRCodeWriter.m
    ZXQRCodeReader.m )

add_library( qrcode OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_link_libraries( qrcode PRIVATE common core )
target_sources( qrcode
    PUBLIC
        $<TARGET_OBJECTS:qrcode-decoder>
        $<TARGET_OBJECTS:qrcode-detector>
        $<TARGET_OBJECTS:qrcode-encoder>
        $<TARGET_OBJECTS:qrcode-multi>
        $<TARGET_OBJECTS:qrcode-multi-detector> )
target_include_directories( qrcode
    PRIVATE
        $<TARGET_PROPERTY:qrcode-decoder,INCLUDE_DIRECTORIES>
        $<TARGET_PROPERTY:qrcode-detector,INCLUDE_DIRECTORIES>
        $<TARGET_PROPERTY:qrcode-encoder,INCLUDE_DIRECTORIES>
        $<TARGET_PROPERTY:qrcode-multi,INCLUDE_DIRECTORIES>
        $<TARGET_PROPERTY:qrcode-multi-detector,INCLUDE_DIRECTORIES>
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET qrcode APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    
add_subdirectory( encoder )
add_subdirectory( multi )
add_subdirectory( decoder )
add_subdirectory( detector )
