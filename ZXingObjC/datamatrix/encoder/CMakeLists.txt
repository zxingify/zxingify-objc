cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-datamatrix-encoder )

set( HEADER_FILES
    ZXDataMatrixBase256Encoder.h
    ZXDataMatrixASCIIEncoder.h
    ZXDataMatrixSymbolInfo144.h
    ZXDataMatrixEncoderContext.h
    ZXDataMatrixSymbolInfo.h
    ZXDataMatrixTextEncoder.h
    ZXDataMatrixDefaultPlacement.h
    ZXDataMatrixHighLevelEncoder.h
    ZXDataMatrixErrorCorrection.h
    ZXDataMatrixX12Encoder.h
    ZXDataMatrixEdifactEncoder.h
    ZXDataMatrixEncoder.h
    ZXDataMatrixC40Encoder.h )

set( SOURCE_FILES 
    ZXDataMatrixX12Encoder.m
    ZXDataMatrixEdifactEncoder.m
    ZXDataMatrixErrorCorrection.m
    ZXDataMatrixC40Encoder.m
    ZXDataMatrixEncoderContext.m
    ZXDataMatrixSymbolInfo144.m
    ZXDataMatrixASCIIEncoder.m
    ZXDataMatrixBase256Encoder.m
    ZXDataMatrixSymbolInfo.m
    ZXDataMatrixDefaultPlacement.m
    ZXDataMatrixHighLevelEncoder.m
    ZXDataMatrixTextEncoder.m )

add_library( datamatrix-encoder OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_link_libraries( datamatrix-encoder PRIVATE common core )
target_include_directories( datamatrix-encoder
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET datamatrix-encoder APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    