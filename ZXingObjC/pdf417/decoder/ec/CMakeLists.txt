cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-pdf417-decoder-ec )

set( HEADER_FILES
    ZXModulusGF.h
    ZXPDF417ECErrorCorrection.h
    ZXModulusPoly.h )

set( SOURCE_FILES 
    ZXModulusPoly.m
    ZXModulusGF.m
    ZXPDF417ECErrorCorrection.m )

add_library( pdf417-decoder-ec OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_link_libraries( pdf417-decoder-ec PRIVATE common )
target_include_directories( pdf417-decoder-ec
    PRIVATE
        $<TARGET_PROPERTY:pdf417,INCLUDE_DIRECTORIES>
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET pdf417-decoder-ec APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    