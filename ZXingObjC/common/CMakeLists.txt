cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-common )

set( HEADER_FILES
    ZXGlobalHistogramBinarizer.h
    ZXCharacterSetECI.h
    ZXHybridBinarizer.h
    ZXDefaultGridSampler.h
    ZXPerspectiveTransform.h
    ZXBoolArray.h
    ZXBitMatrix.h
    ZXDecoderResult.h
    ZXIntArray.h
    ZXBitSource.h
    ZXStringUtils.h
    ZXDecimal.h
    ZXDetectorResult.h
    ZXByteArray.h
    ZXGridSampler.h
    ZXBitArray.h )

set( SOURCE_FILES 
    ZXDecimal.m
    ZXStringUtils.m
    ZXDetectorResult.m
    ZXGridSampler.m
    ZXByteArray.m
    ZXBitArray.m
    ZXHybridBinarizer.m
    ZXCharacterSetECI.m
    ZXGlobalHistogramBinarizer.m
    ZXBoolArray.m
    ZXPerspectiveTransform.m
    ZXDefaultGridSampler.m
    ZXDecoderResult.m
    ZXBitMatrix.m
    ZXBitSource.m
    ZXIntArray.m )

add_library( common OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_sources( common
    PUBLIC
        $<TARGET_OBJECTS:common-detector>
        $<TARGET_OBJECTS:common-reedsolomon> )
target_include_directories( common
    PRIVATE
        $<TARGET_PROPERTY:core,INCLUDE_DIRECTORIES>
    PUBLIC
        $<TARGET_PROPERTY:common-detector,INCLUDE_DIRECTORIES>
        $<TARGET_PROPERTY:common-reedsolomon,INCLUDE_DIRECTORIES>
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET common APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )

add_subdirectory( detector )
add_subdirectory( reedsolomon )
