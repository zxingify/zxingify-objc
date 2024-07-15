cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-pdf417-decoder )

set( HEADER_FILES
    ZXPDF417DetectionResultColumn.h
    ZXPDF417BarcodeValue.h
    ZXPDF417ScanningDecoder.h
    ZXPDF417BarcodeMetadata.h
    ZXPDF417DetectionResultRowIndicatorColumn.h
    ZXPDF417DetectionResult.h
    ZXPDF417Codeword.h
    ZXPDF417CodewordDecoder.h
    ZXPDF417DecodedBitStreamParser.h
    ZXPDF417BoundingBox.h )

set( SOURCE_FILES 
    ZXPDF417CodewordDecoder.m
    ZXPDF417DecodedBitStreamParser.m
    ZXPDF417BoundingBox.m
    ZXPDF417BarcodeMetadata.m
    ZXPDF417ScanningDecoder.m
    ZXPDF417BarcodeValue.m
    ZXPDF417DetectionResultColumn.m
    ZXPDF417Codeword.m
    ZXPDF417DetectionResult.m
    ZXPDF417DetectionResultRowIndicatorColumn.m )

add_library( pdf417-decoder OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_link_libraries( pdf417-decoder PRIVATE pdf417-decoder-ec )
target_include_directories( pdf417-decoder
    PRIVATE
        $<TARGET_PROPERTY:pdf417,INCLUDE_DIRECTORIES>
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET pdf417-decoder APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    
add_subdirectory( ec )
