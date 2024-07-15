cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-datamatrix )

set( HEADER_FILES
    ZXDataMatrixWriter.h
    ZXDataMatrixReader.h
    ZXingObjCDataMatrix.h )

set( SOURCE_FILES 
    ZXDataMatrixReader.m
    ZXDataMatrixWriter.m )

add_library( datamatrix OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_sources( datamatrix
    PUBLIC
        $<TARGET_OBJECTS:datamatrix-decoder>
        $<TARGET_OBJECTS:datamatrix-detector>
        $<TARGET_OBJECTS:datamatrix-encoder> )
target_link_libraries( datamatrix
    PRIVATE
        common
        core )
target_include_directories( datamatrix
    PRIVATE
        $<TARGET_PROPERTY:datamatrix-decoder,INCLUDE_DIRECTORIES>
        $<TARGET_PROPERTY:datamatrix-detector,INCLUDE_DIRECTORIES>
        $<TARGET_PROPERTY:datamatrix-encoder,INCLUDE_DIRECTORIES>
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET datamatrix APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    
add_subdirectory( encoder )
add_subdirectory( decoder )
add_subdirectory( detector )
