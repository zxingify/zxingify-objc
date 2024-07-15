cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-qrcode-encoder )

set( HEADER_FILES
    ZXQRCodeMatrixUtil.h
    ZXQRCodeEncoder.h
    ZXQRCodeBlockPair.h
    ZXQRCodeMaskUtil.h
    ZXQRCode.h )

set( SOURCE_FILES 
    ZXQRCodeMaskUtil.m
    ZXQRCode.m
    ZXQRCodeEncoder.m
    ZXQRCodeMatrixUtil.m
    ZXQRCodeBlockPair.m )

add_library( qrcode-encoder OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_link_libraries( qrcode-encoder PRIVATE common common-reedsolomon core qrcode-decoder )
target_include_directories( qrcode-encoder
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET qrcode-encoder APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    