cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-core )

set( HEADER_FILES
    ZXResult.h
    ZXErrors.h
    ZXRGBLuminanceSource.h
    ZXResultPoint.h
    ZXDimension.h
    ZXEncodeHints.h
    ZXDecodeHints.h
    ZXInvertedLuminanceSource.h
    ZXLuminanceSource.h
    ZXResultPointCallback.h
    ZXBinaryBitmap.h
    ZXReader.h
    ZXingObjCCore.h
    ZXPlanarYUVLuminanceSource.h
    ZXByteMatrix.h
    ZXResultMetadataType.h
    ZXWriter.h
    ZXBarcodeFormat.h
    ZXBinarizer.h )

set( SOURCE_FILES 
    ZXPlanarYUVLuminanceSource.m
    ZXByteMatrix.m
    ZXBinarizer.m
    ZXErrors.m
    ZXResult.m
    ZXEncodeHints.m
    ZXDimension.m
    ZXResultPoint.m
    ZXRGBLuminanceSource.m
    ZXLuminanceSource.m
    ZXInvertedLuminanceSource.m
    ZXDecodeHints.m
    ZXBinaryBitmap.m )

add_library( core OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_include_directories( core
    PRIVATE
        $<TARGET_PROPERTY:common,INCLUDE_DIRECTORIES>
        $<TARGET_PROPERTY:common-detector,INCLUDE_DIRECTORIES>
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET core APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    