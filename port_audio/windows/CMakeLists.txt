cmake_minimum_required(VERSION 3.15)
set(PROJECT_NAME "port_audio")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "port_audio_plugin")

add_library(${PLUGIN_NAME} SHARED
  "port_audio_plugin.cpp"
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

# List of absolute paths to libraries that should be bundled with the plugin
set(port_audio_bundled_libraries
  "${CMAKE_CURRENT_SOURCE_DIR}/library/port_audio_native.dll"
  PARENT_SCOPE
)
