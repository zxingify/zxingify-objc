cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-aztec )

set( HEADER_FILES
    ZXAztecWriter.h
    ZXingObjCAztec.h
    ZXAztecDetectorResult.h
    ZXAztecReader.h )

set( SOURCE_FILES 
    ZXAztecDetectorResult.m
    ZXAztecReader.m
    ZXAztecWriter.m )

add_library( aztec OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_sources( aztec
    PUBLIC
        $<TARGET_OBJECTS:aztec-decoder>
        $<TARGET_OBJECTS:aztec-detector>
        $<TARGET_OBJECTS:aztec-encoder> )
set_property( TARGET aztec APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
target_link_libraries( aztec
    PUBLIC
        common
        common-detector
        common-reedsolomon
        core )
target_include_directories( aztec
    PRIVATE
        $<TARGET_PROPERTY:aztec-decoder,INCLUDE_DIRECTORIES>
        $<TARGET_PROPERTY:aztec-detector,INCLUDE_DIRECTORIES>
        $<TARGET_PROPERTY:aztec-encoder,INCLUDE_DIRECTORIES>
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )

add_subdirectory( encoder )
add_subdirectory( decoder )
add_subdirectory( detector )
