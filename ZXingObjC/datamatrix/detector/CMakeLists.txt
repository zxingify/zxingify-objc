cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-datamatrix-detector )

set( HEADER_FILES
    ZXDataMatrixDetector.h )

set( SOURCE_FILES 
    ZXDataMatrixDetector.m )

add_library( datamatrix-detector OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_link_libraries( datamatrix-detector PRIVATE common common-detector core datamatrix-decoder )
target_include_directories( datamatrix-detector
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET datamatrix-detector APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    