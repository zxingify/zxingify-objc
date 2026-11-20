cmake_minimum_required( VERSION 3.5 )

project( ZXingObjC-oned )

set( HEADER_FILES
    ZXITFReader.h
    ZXUPCAWriter.h
    ZXCode93Writer.h
    ZXEAN8Writer.h
    ZXCodaBarWriter.h
    ZXMultiFormatOneDReader.h
    ZXUPCEANExtension5Support.h
    ZXingObjCOneD.h
    ZXUPCEANExtension2Support.h
    ZXCode128Reader.h
    ZXUPCEANWriter.h
    ZXUPCEANExtensionSupport.h
    ZXEAN13Writer.h
    ZXCode39Writer.h
    ZXUPCEReader.h
    ZXOneDReader.h
    ZXEAN8Reader.h
    ZXCodaBarReader.h
    ZXCode93Reader.h
    ZXEANManufacturerOrgSupport.h
    ZXMultiFormatUPCEANReader.h
    ZXITFWriter.h
    ZXUPCAReader.h
    ZXEAN13Reader.h
    ZXOneDimensionalCodeWriter.h
    ZXUPCEWriter.h
    ZXCode39Reader.h
    ZXCode128Writer.h
    ZXUPCEANReader.h )

set( SOURCE_FILES 
    ZXCode93Reader.m
    ZXEANManufacturerOrgSupport.m
    ZXCodaBarReader.m
    ZXEAN8Reader.m
    ZXOneDReader.m
    ZXUPCAReader.m
    ZXITFWriter.m
    ZXMultiFormatUPCEANReader.m
    ZXCode39Reader.m
    ZXUPCEWriter.m
    ZXOneDimensionalCodeWriter.m
    ZXEAN13Reader.m
    ZXCode128Writer.m
    ZXUPCEANReader.m
    ZXUPCAWriter.m
    ZXITFReader.m
    ZXUPCEANExtension5Support.m
    ZXMultiFormatOneDReader.m
    ZXCodaBarWriter.m
    ZXEAN8Writer.m
    ZXCode93Writer.m
    ZXCode128Reader.m
    ZXUPCEANWriter.m
    ZXUPCEANExtension2Support.m
    ZXUPCEReader.m
    ZXCode39Writer.m
    ZXEAN13Writer.m
    ZXUPCEANExtensionSupport.m )

add_library( oned OBJECT ${HEADER_FILES} ${SOURCE_FILES} )
target_sources( oned
    PUBLIC
        $<TARGET_OBJECTS:oned-rss>
        $<TARGET_OBJECTS:oned-rss-expanded>
        $<TARGET_OBJECTS:oned-rss-expanded-decoders> )
target_link_libraries( oned PRIVATE common core )
target_include_directories( oned
    PRIVATE
        $<TARGET_PROPERTY:oned-rss,INCLUDE_DIRECTORIES>
        $<TARGET_PROPERTY:oned-rss-expanded,INCLUDE_DIRECTORIES>
        $<TARGET_PROPERTY:oned-rss-expanded-decoders,INCLUDE_DIRECTORIES>
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR} )
set_property( TARGET oned APPEND_STRING PROPERTY COMPILE_FLAGS -fobjc-arc )
    
add_subdirectory( rss )
