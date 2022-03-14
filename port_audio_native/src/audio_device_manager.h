//
// Created by Song Fei on 2021/10/20.
//

#ifndef PORT_AUDIO_NATIVE_AUDIO_DEVICE_MANAGER_H
#define PORT_AUDIO_NATIVE_AUDIO_DEVICE_MANAGER_H

#include <stdint.h>
#include "common.h"

typedef struct  {
    int32_t deviceIndex;
    const char* name;
    int32_t maxInputChannelCount;
    int32_t maxOutputChannelCount;

    double defaultSamplingRate;
} NativeAudioDeviceInfo;

typedef struct  {
    NativeAudioDeviceInfo** list;
    int32_t count;
} NativeAudioDeviceInfoList;


EXPORT_API void port_audio_native_initialize(void* dartApiData, int64_t callbackPort);
EXPORT_API void port_audio_native_terminate();

EXPORT_API NativeAudioDeviceInfo* port_audio_native_get_default_input_device();
EXPORT_API NativeAudioDeviceInfo* port_audio_native_get_default_output_device();

EXPORT_API NativeAudioDeviceInfoList* port_audio_native_get_input_device_list();
EXPORT_API NativeAudioDeviceInfoList* port_audio_native_get_output_device_list();

EXPORT_API void port_audio_native_destroy_device_info(NativeAudioDeviceInfo* info);
EXPORT_API void port_audio_native_destroy_device_info_list(NativeAudioDeviceInfoList* list);

typedef enum {
    native_callback_type_create_input_stream = 1,
    native_callback_type_start_input_stream,
    native_callback_type_stop_input_stream,
    native_callback_type_abort_input_stream,
    native_callback_type_destroy_input_stream,

} NativeCallbackType;

void port_audio_native_callback(NativeCallbackType type, char* callbackId, int32_t code, void* result);

#endif //PORT_AUDIO_NATIVE_AUDIO_DEVICE_MANAGER_H
