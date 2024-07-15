cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC VERSION 3.4.5 LANGUAGES C OBJC )

function( LinkFrameworks )
    set( options )
    set( oneValueArgs
            TARGET )
    set( multiValueArgs )
    cmake_parse_arguments( arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    set( TARGET ${arg_TARGET} )

    find_library( FOUNDATION_FRAMEWORK Foundation )
    find_library( AVFOUNDATION_FRAMEWORK AVFoundation )
    find_library( QUARTZCORE_FRAMEWORK QuartzCore )
    target_link_libraries( ${TARGET} PUBLIC ${FOUNDATION_FRAMEWORK} ${AVFOUNDATION_FRAMEWORK} ${QUARTZCORE_FRAMEWORK} )

    if( CMAKE_SYSTEM_NAME STREQUAL Darwin )
        find_library( COCOA_FRAMEWORK Cocoa )
        find_library( COREMEDIA_FRAMEWORK CoreMedia )
        target_link_libraries( ${TARGET} PUBLIC ${COCOA_FRAMEWORK} ${COREMEDIA_FRAMEWORK} )
    endif()

    if( CMAKE_SYSTEM_NAME STREQUAL iOS )
        find_library( UIKIT_FRAMEWORK UIKit )
        find_library( COREGRAPHICS_FRAMEWORK CoreGraphics )
        find_library( COREVIDEO_FRAMEWORK CoreVideo )
        find_library( IMAGEIO_FRAMEWORK ImageIO )
        target_link_libraries( ${TARGET}
            PUBLIC
                ${COREGRAPHICS_FRAMEWORK}
                ${COREVIDEO_FRAMEWORK}
                ${IMAGEIO_FRAMEWORK}
                ${UIKIT_FRAMEWORK} )
    endif()
endfunction( LinkFrameworks )

function( GenerateUmbrellaHeader )
    set( options )
    set( oneValueArgs OUTPUT )
    set( multiValueArgs HEADERS )
    cmake_parse_arguments( arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    set( HEADERS ${arg_HEADERS} )
    set( OUTPUT ${arg_OUTPUT} )

    foreach( HEADER ${HEADERS} )
        get_filename_component( HEADER_NAME ${HEADER} NAME )
        string( APPEND ZXINGOBJC_UMBRELLA_IMPORTS "#import <ZXingObjC/${HEADER_NAME}>\n" )
    endforeach()
    set( GENERATED_UMBRELLA_HEADER ${CMAKE_CURRENT_BINARY_DIR}/ZXingObjC.h )
    configure_file( ZXingObjC.h.in ${GENERATED_UMBRELLA_HEADER} )
    set( ${OUTPUT} ${GENERATED_UMBRELLA_HEADER} PARENT_SCOPE )
endfunction( GenerateUmbrellaHeader )

option( ZXINGOBJC_AZTEC "Aztec barcode support" TRUE )
option( ZXINGOBJC_DATAMATRIX "Datamatrix support" TRUE )
option( ZXINGOBJC_MAXICODE "Maxicode support" TRUE )
option( ZXINGOBJC_ONED "1D barcode support" TRUE )
option( ZXINGOBJC_PDF417 "PDF417 support" TRUE )
option( ZXINGOBJC_QRCODE "QR code support" TRUE )

set( CMAKE_POSITION_INDEPENDENT_CODE on )

add_subdirectory( client )
add_subdirectory( common )
add_subdirectory( core )
add_subdirectory( multi )

add_subdirectory( aztec )
add_subdirectory( datamatrix )
add_subdirectory( maxicode )
add_subdirectory( oned )
add_subdirectory( pdf417 )
add_subdirectory( qrcode )

set( HEADER_FILES
        ZXMultiFormatReader.h
        ZXMultiFormatWriter.h )

set( SOURCE_FILES
        ZXMultiFormatReader.m
        ZXMultiFormatWriter.m )

add_library( zxing-objects OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_sources( zxing-objects
    PUBLIC
        $<TARGET_OBJECTS:client>
        $<TARGET_OBJECTS:common>
        $<TARGET_OBJECTS:core>
        $<TARGET_OBJECTS:multi> )
target_link_libraries( zxing-objects PUBLIC client common core multi )

set( ZXINGOBJC_PUBLIC_HEADERS )
list( APPEND ZXINGOBJC_PUBLIC_HEADERS ${CMAKE_CURRENT_LIST_DIR}/core/ZXingObjCCore.h )

target_compile_definitions( zxing-objects PUBLIC ZXINGOBJC_USE_SUBSPECS )
if( ZXINGOBJC_AZTEC )
    target_compile_definitions( zxing-objects PUBLIC ZXINGOBJC_AZTEC )
    target_sources( zxing-objects PUBLIC $<TARGET_OBJECTS:aztec> )
    target_link_libraries( zxing-objects PUBLIC aztec )
    list( APPEND ZXINGOBJC_PUBLIC_HEADERS ${CMAKE_CURRENT_LIST_DIR}/aztec/ZXingObjCAztec.h )
endif( ZXINGOBJC_AZTEC )

if( ZXINGOBJC_DATAMATRIX )
    target_compile_definitions( zxing-objects PUBLIC ZXINGOBJC_DATAMATRIX )
    target_sources( zxing-objects PUBLIC $<TARGET_OBJECTS:datamatrix> )
    target_link_libraries( zxing-objects PUBLIC datamatrix )
    list( APPEND ZXINGOBJC_PUBLIC_HEADERS ${CMAKE_CURRENT_LIST_DIR}/datamatrix/ZXingObjCDataMatrix.h )
endif( ZXINGOBJC_DATAMATRIX )

if( ZXINGOBJC_MAXICODE )
    target_compile_definitions( zxing-objects PUBLIC ZXINGOBJC_MAXICODE )
    target_sources( zxing-objects PUBLIC $<TARGET_OBJECTS:maxicode> )
    target_link_libraries( zxing-objects PUBLIC maxicode )
    list( APPEND ZXINGOBJC_PUBLIC_HEADERS ${CMAKE_CURRENT_LIST_DIR}/maxicode/ZXingObjCMaxiCode.h )
endif( ZXINGOBJC_MAXICODE )

if( ZXINGOBJC_ONED )
    target_compile_definitions( zxing-objects PUBLIC ZXINGOBJC_ONED )
    target_sources( zxing-objects PUBLIC $<TARGET_OBJECTS:oned> )
    target_link_libraries( zxing-objects PUBLIC oned )
    list( APPEND ZXINGOBJC_PUBLIC_HEADERS ${CMAKE_CURRENT_LIST_DIR}/oned/ZXingObjCOneD.h )
endif( ZXINGOBJC_ONED )

if( ZXINGOBJC_PDF417 )
    target_compile_definitions( zxing-objects PUBLIC ZXINGOBJC_PDF417 )
    target_sources( zxing-objects PUBLIC $<TARGET_OBJECTS:pdf417> )
    target_link_libraries( zxing-objects PUBLIC pdf417 )
    list( APPEND ZXINGOBJC_PUBLIC_HEADERS ${CMAKE_CURRENT_LIST_DIR}/pdf417/ZXingObjCPDF417.h )
endif( ZXINGOBJC_PDF417 )

if( ZXINGOBJC_QRCODE )
    target_compile_definitions( zxing-objects PUBLIC ZXINGOBJC_QRCODE )
    target_sources( zxing-objects PUBLIC $<TARGET_OBJECTS:qrcode> )
    target_link_libraries( zxing-objects PUBLIC qrcode )
    list( APPEND ZXINGOBJC_PUBLIC_HEADERS ${CMAKE_CURRENT_LIST_DIR}/qrcode/ZXingObjCQRCode.h )
endif( ZXINGOBJC_QRCODE )

list( APPEND ZXINGOBJC_PUBLIC_HEADERS ${CMAKE_CURRENT_LIST_DIR}/ZXMultiFormatReader.h )
list( APPEND ZXINGOBJC_PUBLIC_HEADERS ${CMAKE_CURRENT_LIST_DIR}/ZXMultiFormatWriter.h )

add_library( zxing-static STATIC )
target_link_libraries( zxing-static PUBLIC zxing-objects )
set_target_properties( zxing-static
    PROPERTIES
        OUTPUT_NAME ZXingObjC )

add_library( zxing-shared SHARED )
LinkFrameworks( TARGET zxing-shared )
target_link_libraries( zxing-shared PUBLIC zxing-static )
set_target_properties( zxing-shared
    PROPERTIES
        OUTPUT_NAME ZXingObjC )

GenerateUmbrellaHeader( HEADERS ${ZXINGOBJC_PUBLIC_HEADERS} OUTPUT UMBRELLA_HEADER )
list( APPEND ZXINGOBJC_PUBLIC_HEADERS ${UMBRELLA_HEADER} )
add_library( zxing-framework SHARED dummy.m ${ZXINGOBJC_PUBLIC_HEADERS} )
LinkFrameworks( TARGET zxing-framework )
target_link_libraries( zxing-framework PUBLIC zxing-static )
set_target_properties( zxing-framework
    PROPERTIES
        LINKER_LANGUAGE C
        FRAMEWORK TRUE
        OUTPUT_NAME ZXingObjC
        MACOSX_FRAMEWORK_IDENTIFIER com.zxing.ZXingObjC
        PUBLIC_HEADER "${ZXINGOBJC_PUBLIC_HEADERS}" )
