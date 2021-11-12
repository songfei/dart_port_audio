//
// Created by Song Fei on 2021/10/20.
//

#ifndef PORT_AUDIO_NATIVE_AUDIO_DEVICE_MANAGER_H
#define PORT_AUDIO_NATIVE_AUDIO_DEVICE_MANAGER_H

#include <stdint.h>

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

void port_audio_native_initialize(void* dartApiData);
void port_audio_native_terminate();

NativeAudioDeviceInfo* port_audio_native_get_default_input_device();
NativeAudioDeviceInfo* port_audio_native_get_default_output_device();

NativeAudioDeviceInfoList* port_audio_native_get_input_device_list();
NativeAudioDeviceInfoList* port_audio_native_get_output_device_list();

void port_audio_native_destroy_device_info(NativeAudioDeviceInfo* info);
void port_audio_native_destroy_device_info_list(NativeAudioDeviceInfoList* list);

#endif //PORT_AUDIO_NATIVE_AUDIO_DEVICE_MANAGER_H
