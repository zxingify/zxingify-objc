cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-maxicode-decoder )

set( HEADER_FILES
    ZXMaxiCodeDecoder.h
    ZXMaxiCodeDecodedBitStreamParser.h
    ZXMaxiCodeBitMatrixParser.h )

set( SOURCE_FILES 
    ZXMaxiCodeDecoder.m
    ZXMaxiCodeDecodedBitStreamParser.m
    ZXMaxiCodeBitMatrixParser.m )

add_library( maxicode-decoder OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_link_libraries( maxicode-decoder PRIVATE common common-reedsolomon core )
target_include_directories( maxicode-decoder
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET maxicode-decoder APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    