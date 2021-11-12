cmake_minimum_required(VERSION 3.20)
project(port_audio_native C)

set(CMAKE_C_STANDARD 99)

include_directories(
    include
    lib/portaudio/include
)

link_directories(
#    lib/portaudio/ios
    lib/portaudio/macos
#    lib/portaudio/android/aarch64
#    lib/portaudio/android/armv7a
)


add_library(port_audio_native SHARED
    include/dart_api_dl.c
    src/audio_device_manager.c
    src/audio_device_manager.h
        src/audio_input_stream.c)

set(PUBLIC_HEADERS
        src/audio_device_manager.h
#        src/audio_input_stream.h
        )

set_target_properties(port_audio_native PROPERTIES
    FRAMEWORK TRUE
    FRAMEWORK_VERSION A
    MACOSX_FRAMEWORK_IDENTIFIER org.songfei.portaudionative
    MACOSX_FRAMEWORK_SHORT_VERSION_STRING 1.0.0
    MACOSX_FRAMEWORK_BUNDLE_VERSION 1.0.0
    VERSION 1.0.0
    XCODE_ATTRIBUTE_ENABLE_BITCODE "NO"
    PUBLIC_HEADER ${PUBLIC_HEADERS}
)

target_link_libraries(port_audio_native portaudio)
target_link_libraries(port_audio_native "-framework CoreAudio")
target_link_libraries(port_audio_native "-framework AudioToolbox")
target_link_libraries(port_audio_native "-framework AudioUnit")
target_link_libraries(port_audio_native "-framework CoreServices")
target_link_libraries(port_audio_native "-framework Carbon")

