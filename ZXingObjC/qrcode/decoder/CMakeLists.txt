cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-qrcode-decoder )

set( HEADER_FILES
    ZXQRCodeMode.h
    ZXQRCodeFormatInformation.h
    ZXQRCodeDecodedBitStreamParser.h
    ZXQRCodeErrorCorrectionLevel.h
    ZXQRCodeDecoderMetaData.h
    ZXQRCodeDecoder.h
    ZXQRCodeDataMask.h
    ZXQRCodeBitMatrixParser.h
    ZXQRCodeVersion.h
    ZXQRCodeDataBlock.h )

set( SOURCE_FILES 
    ZXQRCodeDecoderMetaData.m
    ZXQRCodeDataMask.m
    ZXQRCodeDecoder.m
    ZXQRCodeVersion.m
    ZXQRCodeBitMatrixParser.m
    ZXQRCodeDataBlock.m
    ZXQRCodeMode.m
    ZXQRCodeFormatInformation.m
    ZXQRCodeDecodedBitStreamParser.m
    ZXQRCodeErrorCorrectionLevel.m )

add_library( qrcode-decoder OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_link_libraries( qrcode-decoder PRIVATE common common-reedsolomon core )
target_include_directories( qrcode-decoder
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET qrcode-decoder APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    