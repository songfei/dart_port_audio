cmake_minimum_required(VERSION 3.20)
project(port_audio_native C)

set(CMAKE_C_STANDARD 99)

include_directories(
    include
    lib/portaudio/include
    lib/pthread/include
)


if(WIN32)
    link_directories(
        lib/portaudio/windows
        lib/pthread/lib/x64
    )
elseif(APPLE)
    link_directories(
            lib/portaudio/macos
    )
elseif(ANDROID)
    link_directories(
            lib/portaudio/windows
    )
endif()


add_library(port_audio_native SHARED
        include/internal/dart_api_dl_impl.h
        include/dart_api.h
        include/dart_api_dl.c
        include/dart_api_dl.h
        include/dart_native_api.h
        include/dart_tools_api.h
        include/dart_version.h
        src/audio_device_manager.c
        src/audio_input_stream.c
        src/common.h)

set(PUBLIC_HEADERS
    src/audio_device_manager.h
    src/audio_input_stream.h
)

target_link_libraries(port_audio_native portaudio pthreadVC2)

if(APPLE)
    set_target_properties(port_audio_native PROPERTIES
        FRAMEWORK TRUE
        FRAMEWORK_VERSION A
        MACOSX_FRAMEWORK_IDENTIFIER org.songfei.portaudionative
        MACOSX_FRAMEWORK_SHORT_VERSION_STRING 1.0.0
        MACOSX_FRAMEWORK_BUNDLE_VERSION 1.0.0
        VERSION 1.0.0
        XCODE_ATTRIBUTE_ENABLE_BITCODE "NO"
#        PUBLIC_HEADER ${PUBLIC_HEADERS}
    )


    target_link_libraries(port_audio_native "-framework CoreAudio")
    target_link_libraries(port_audio_native "-framework AudioToolbox")
    target_link_libraries(port_audio_native "-framework AudioUnit")
    target_link_libraries(port_audio_native "-framework CoreServices")
    target_link_libraries(port_audio_native "-framework Carbon")
endif()