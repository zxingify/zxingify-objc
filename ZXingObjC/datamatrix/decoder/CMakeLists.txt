cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-datamatrix-decoder )

set( HEADER_FILES
    ZXDataMatrixDecoder.h
    ZXDataMatrixVersion.h
    ZXDataMatrixDecodedBitStreamParser.h
    ZXDataMatrixBitMatrixParser.h
    ZXDataMatrixDataBlock.h )

set( SOURCE_FILES 
    ZXDataMatrixDecodedBitStreamParser.m
    ZXDataMatrixBitMatrixParser.m
    ZXDataMatrixDataBlock.m
    ZXDataMatrixDecoder.m
    ZXDataMatrixVersion.m )

add_library( datamatrix-decoder OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_link_libraries( datamatrix-decoder PRIVATE common common-reedsolomon core )
target_include_directories( datamatrix-decoder
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET datamatrix-decoder APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    