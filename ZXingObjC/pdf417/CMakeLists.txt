cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-pdf417 )

set( HEADER_FILES
    ZXingObjCPDF417.h
    ZXPDF417Reader.h
    ZXPDF417ResultMetadata.h
    ZXPDF417Writer.h
    ZXPDF417Common.h )

set( SOURCE_FILES 
    ZXPDF417Writer.m
    ZXPDF417Common.m
    ZXPDF417Reader.m
    ZXPDF417ResultMetadata.m )

add_library( pdf417 OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_sources( pdf417
    PUBLIC
        $<TARGET_OBJECTS:pdf417-decoder>
        $<TARGET_OBJECTS:pdf417-decoder-ec>
        $<TARGET_OBJECTS:pdf417-detector>
        $<TARGET_OBJECTS:pdf417-encoder> )
target_link_libraries( pdf417 PRIVATE common core multi )
target_include_directories( pdf417
    PRIVATE
        $<TARGET_PROPERTY:pdf417-decoder,INCLUDE_DIRECTORIES>
        $<TARGET_PROPERTY:pdf417-decoder-ec,INCLUDE_DIRECTORIES>
        $<TARGET_PROPERTY:pdf417-detector,INCLUDE_DIRECTORIES>
        $<TARGET_PROPERTY:pdf417-encoder,INCLUDE_DIRECTORIES>
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET pdf417 APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    
add_subdirectory( encoder )
add_subdirectory( decoder )
add_subdirectory( detector )
